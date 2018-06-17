
##createtablehvac
CREATE EXTERNAL TABLE IF NOT EXISTS HVAC(date string,time string,targettemp int,actualtemp int, 
system string,systemage int,buldingid string) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','  
STORED AS TEXTFILE LOCATION '/user/cloudera/sensordata/hvac'  
tblproperties("skip.header.line.count"="1",'serialization.null.format'='') ;



 ##createtablebuilding	
CREATE EXTERNAL TABLE IF NOT EXISTS building(buildingid int,buildingmgr string,buildingage int, 
HVACproduct string,country string) 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' STORED AS TEXTFILE LOCATION '/user/cloudera/sensordata/building'  
tblproperties("skip.header.line.count"="1",'serialization.null.format'='') ;



##calculatevariables
create table analysis1 as select buldingid,temp_diff,temprange, 
case 
when temprange in ("normal") then 0 
else 1 end as extremetemp 
from(SELECT buldingid,temp_diff, 
case 
when(temp_diff>5) THEN "hot" 
when(temp_diff<-5)then "cold" 
else "normal" end as temprange 
from(SELECT buldingid,(actualtemp-targettemp) as temp_diff FROM hvac)result1)result2 



##countoptimaloutofrangetemprature
create table extremetep as  
select count(a.extremetemp) as outsideoptimaltemprature,b.country from analysis1 a join building b where cast(a.buldingid as int)=b.buildingid and a.extremetemp >0  
group by b.country 



##hot cold offices by country
create table hot_cold as 
SELECT a.temprange,count(a.temprange) as totaloffice,b.country FROM analysis1 a JOIN building b WHERE 
b.buildingid=cast(a.buldingid as INT) and a.temprange!="normal" GROUP BY a.temprange,b.country 



##extremetemp by hvac product 
create table bestproduct as  
SELECT count(a.extremetemp) as appropriaterange,b.hvacproduct FROM analysis1 a join building b 
WHERE b.buildingid=cast(a.buldingid as int) and a.extremetemp =0 GROUP BY b.hvacproduct