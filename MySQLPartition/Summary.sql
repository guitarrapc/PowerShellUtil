-- Step1
/* PKの確認 - idではなくDateで行うので、対象のDateカラムがPKIに入っていることを確認 */
ALTER TABLE hoge DROP PRIMARY KEY
, ADD PRIMARY KEY (id, created); 

-- Ste2
/* UNIQUE KEYにPKを含める */

/* 先に新しいUNIQUE KEYを追加 */
ALTER TABLE hoge ADD UNIQUE (history_id, no, id, created); 
/* 次に古いUNIQUE KEYを削除 */
ALTER TABLE hoge DROP INDEX history_id;
	


-- Step2 PKIを含めて Partitioning実施
ALTER TABLE PARTITION BY
	range(to_days(created_days))( 
		PARTITION pyyyymmdd VALUES LESS THAN (to_days('yyyy-MM-dd hh:mm:ss')) COMMENT = ''
		, PARTITION p1 VALUES LESS THAN (to_days()) COMMENT = ''
		, PARTITION p2 VALUES LESS THAN (to_days()) COMMENT = ''
		, PARTITION p3 VALUES LESS THAN (to_days()) COMMENT = ''
	); 


/*
REORGANIZE PARTITION するにも ADD PARTITION するにもテーブルロックが避けられない
事前にまとめてガガッとパーティション作っちゃう場合が多い

が、Daily処理でのAdd Partition操作が一瞬のため、ReorganizeよりはAddで。
*/



-- Step 3 Add Partition 

ALTER TABLE test
    ADD PARTITION ( 
			PARTITION p6 VALUES LESS THAN (TO_DAYS('2013-04-09')) COMMENT = '2013-04-08',
			PARTITION p7 VALUES LESS THAN (TO_DAYS('2013-04-10')) COMMENT = '2013-04-09'
); 



-- Step 4 Drop Partition

ALTER TABLE hoge 
    DROP PARTITION 
		 p20130130,
 		 p20130131
; 



-- Step5 Partitioningの状況
SELECT
	  table_schema
	, table_name
	, partition_method
	, partition_expression
	, partition_comment
	, partition_name
	, partition_ordinal_position
	, table_rows 
FROM
	information_schema.partitions 
WHERE
	table_name = 'hoge'; 




-- Step6 そのPartitionが使われているか
explain partitions 
SELECT
	  * 
FROM
	samples; 



-- Step hoge Remove Partition
ALTER TABLE hoge REMOVE PARTITIONING;







/*
	SAMPLE OF PARTITION
*/


-- ###################################################################################################

-- これはだめ (PKにUNIQUEを加える必要があるが、今度はTypeの問題にあたる)
/*
CREATE TABLE test (
	id INT NOT NULL AUTO_INCREMENT,
	hoge VARCHAR(32) NOT NULL,
	no INT NOT NULL,
	created_dt DATETIME NOT NULL,
	PRIMARY KEY (id,created_dt),
	UNIQUE (no)
) ENGINE=INNODB;
*/


-- PKをUniqueに含めることで、PKの一つでPatritionが可能になる
CREATE TABLE test (
	id INT NOT NULL AUTO_INCREMENT,
	hoge VARCHAR(32) NOT NULL,
	no INT NOT NULL,
	created_dt DATETIME NOT NULL,
	PRIMARY KEY (id,created_dt),
	UNIQUE (id,created_dt,no)
) ENGINE=INNODB;



-- ###################################################################################################


INSERT INTO test 
VALUE 
	(1,'hoge','1','2013-04-03')
,	(2,'hoge','2','2013-04-04')
,	(3,'hoge','3','2013-04-05');



-- ###################################################################################################


ALTER TABLE test
	PARTITION BY RANGE (TO_DAYS(created_dt))( 
			PARTITION p0 VALUES LESS THAN (TO_DAYS('2013-04-03')) COMMENT = '2013-04-03',
			PARTITION p1 VALUES LESS THAN (TO_DAYS('2013-04-04')) COMMENT = '2013-04-04',
			PARTITION p2 VALUES LESS THAN (TO_DAYS('2013-04-05')) COMMENT = '2013-04-05',
			PARTITION p3 VALUES LESS THAN (TO_DAYS('2013-04-06')) COMMENT = '2013-04-06',
			PARTITION p4 VALUES LESS THAN (TO_DAYS('2013-04-07')) COMMENT = '2013-04-07',
			PARTITION p5 VALUES LESS THAN (TO_DAYS('2013-04-08')) COMMENT = '2013-04-08'
	); 



-- Partition追加時の確認SQL
SELECT TO_DAYS(created_dt), TO_DAYS('2013-04-05') FROM test WHERE TO_DAYS(created_dt) = TO_DAYS('2013-04-03');


-- ###################################################################################################
-- ###################################################################################################

