#Project Title:Application of an Externally Developed Algorithm to
#Identify Research Cases and Controlsfrom Electronic Health Record Data: Failures and Successes

create or replace procedure P_req4711_OMOP_SQL as
begin

---------case1--------------------------------

EXECUTE IMMEDIATE 'drop table    cindy_4711_c1 ';
EXECUTE IMMEDIATE 'create table  cindy_4711_c1 as

with v1 as (
select distinct t2.*,
t1.concept_cd, t3.name_char,   t1.SOURCESYSTEM_CD,
t4.*,
COALESCE(t5.contact_date,t1.start_date) as d1

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case1=''1a''

left join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d1
)  as rn2
FROM v1 )t
Where rn2=1) t1
';

------case2:---------------------------------------------

EXECUTE IMMEDIATE 'drop table  cindy_4711_c2a_all';
EXECUTE IMMEDIATE 'create table cindy_4711_c2a_all as

select distinct t2.*,
t1.concept_cd, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
COALESCE(t5.contact_date,t1.start_date) as d1

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case2=''2a''

left join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
';
-------------------------------
EXECUTE IMMEDIATE 'drop table  cindy_4711_c2';
EXECUTE IMMEDIATE 'create table cindy_4711_c2 as

with v1 as (
select distinct t2.mrn,t1.patient_num,t2.pat_id,
t1.concept_cd, t3.name_char, t1.start_date,  t1.SOURCESYSTEM_CD, t4.*,
t5.concept_cd as concept1, t5.name_char as name1, t5.d1,
COALESCE(t6.contact_date,t1.start_date) as d2

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case2=''2b''

inner join cindy_4711_c2a_all t5-------------------------
on t2.pat_id=t5.pat_id

left join sourceuser.epic_pat_enc t6
on t2.pat_id=t6.pat_id
and ''14''||LPAD(t6.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
and ((t6.contact_date between t5.d1 and t5.d1+365)-------------------------(within 1 year after)
or (t6.contact_date is null and t1.start_date between t5.d1 and t5.d1+365)
)
)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d1,d2---c2a (d1) first
)  as rn2
FROM v1 )t
Where rn2=1) t1
';


------case3:---------------------------------------------

EXECUTE IMMEDIATE 'drop table  cindy_4711_c3a_all ';--get all cpt
EXECUTE IMMEDIATE 'create table cindy_4711_c3a_all as

select distinct t2.*,
t1.concept_cd, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
COALESCE(t5.contact_date,t1.start_date) as d1

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case3=''3a''

left join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')

';
-----------------------------
EXECUTE IMMEDIATE 'drop table   CINDY_4711_C3A_ALL_2 ';--get all cpt
EXECUTE IMMEDIATE 'create table  CINDY_4711_C3A_ALL_2 as

select distinct mrn, pat_id, concept_cd, name_char, d1
from CINDY_4711_C3A_ALL
union 
select distinct mrn, pat_id, ''CPT:''||CPT_CODE, DESCRIPTION, ORDERING_DATE
from cindy_4711_0_76140 
';
------------------------------

EXECUTE IMMEDIATE 'drop table  cindy_4711_c3b_1st';---1st dx
EXECUTE IMMEDIATE 'create table cindy_4711_c3b_1st as

with v1 as (
select distinct t2.mrn,t1.patient_num,t2.pat_id,
t1.concept_cd, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
t5.concept_cd as concept1, t5.name_char as name1, t5.d1,----cpt
COALESCE(t6.contact_date,t1.start_date) as d1

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case3=''3b''

inner join cindy_4711_c3a_all_2 t5-------------------------
on t2.pat_id=t5.pat_id

left join sourceuser.epic_pat_enc t6
on t2.pat_id=t6.pat_id
and ''14''||LPAD(t6.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
and ((t6.contact_date between t5.d1 and t5.d1 +365)-------------------------(within 1 year after)
or (t6.contact_date is null and t1.start_date between t5.d1 and t5.d1+365)
)
)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d21, d1---c3b first
)  as rn2
FROM v1 )t
Where rn2=1) t1
';
-------------------------

EXECUTE IMMEDIATE 'drop table  cindy_4711_c3b_latest ';
EXECUTE IMMEDIATE 'create table cindy_4711_c3b_latest as

with v1 as (
select distinct t2.mrn,t1.patient_num,t2.pat_id,
t1.concept_cd, t3.name_char,  t1.SOURCESYSTEM_CD,  t4.*,
t5.concept_cd as concept1, t5.name_char as name1, t5.d1,
COALESCE(t6.contact_date,t1.start_date) as d22

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case3=''3b''

inner join cindy_4711_c3a_all_2 t5-------------------------
on t2.pat_id=t5.pat_id

left join sourceuser.epic_pat_enc t6
on t2.pat_id=t6.pat_id
and ''14''||LPAD(t6.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
and ((t6.contact_date between t5.d1 and t5.d1 +365)--------------------------------(within 1 year after)
or (t6.contact_date is null and t1.start_date between t5.d1 and t5.d1+365)
)
)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d22 desc, d1 desc---c3b first
)  as rn2
FROM v1 )t
Where rn2=1) t1
';
--------------------------------------------

EXECUTE IMMEDIATE 'drop table   cindy_4711_c3d  ';---latest date
EXECUTE IMMEDIATE 'create table  cindy_4711_c3d  as

with v1 as (
select distinct t2.*,
t1.concept_cd, t3.name_char, t1.SOURCESYSTEM_CD, t4.*,
COALESCE(t5.contact_date,t1.start_date) as d4

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case3=''3c''

left join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d4 desc
)  as rn2
FROM v1 )t
Where rn2=1) t1
';
------------------------------
EXECUTE IMMEDIATE 'drop table   CINDY_4711_C3  ';----case3
EXECUTE IMMEDIATE 'create table CINDY_4711_C3  as


with v2 as
(
select distinct t1.pat_id

from CINDY_4711_C3b_latest t1

inner join  CINDY_4711_C3d t2---latest date
on t1.pat_id=t2.pat_id
and t2.d4 >=t1.d22
)
-------------------
select distinct t1.*,
t2.concept_cd as latest_concept, t2.d22

from       CINDY_4711_C3b_1st t1

inner join CINDY_4711_C3b_latest t2
on t1.pat_id=t2.pat_id

left join v2
on t1.pat_id=v2.pat_id

where v2.pat_id is null
';


------case4---------------------------------------------
#previously 5c

EXECUTE IMMEDIATE 'drop table   cindy_4711_5c_e_3rd  ';---get the 3rd
EXECUTE IMMEDIATE 'create table cindy_4711_5c_e_3rd as

with v1 as (
select distinct t2.*,
t5.pat_enc_csn_id, t5.contact_date as d3,
t8.name as visit3

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case5=''5d''

inner join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

inner join cindy_ZC_DISP_ENC_TYPE_visit t8
on t5.ENC_TYPE_C=t8.DISP_ENC_TYPE_C

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')

)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d3, pat_enc_csn_id
)  as rn2
FROM v1 )t
Where rn2=3) t1
';
----------------------------
EXECUTE IMMEDIATE 'drop table   cindy_4711_5c_e_3rd_detail  ';---get the 3rd
EXECUTE IMMEDIATE 'create table cindy_4711_5c_e_3rd_detail as

with v1 as (
select distinct t2.*,
t1.concept_cd as concept3, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
t5.pat_enc_csn_id, t5.contact_date as d3,  t8.name as visit3

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case5=''5d''

inner join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

inner join cindy_4711_5c_e_3rd t6
on t5.PAT_ENC_CSN_ID=t6.PAT_ENC_CSN_ID

inner join cindy_ZC_DISP_ENC_TYPE_visit t8
on t5.ENC_TYPE_C=t8.DISP_ENC_TYPE_C

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')

)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by concept3
)  as rn3
FROM v1 )t
Where rn3=1) t1
';

---------------------------------

EXECUTE IMMEDIATE 'drop table   cindy_4711_5c_e_1st ';---get the 1st
EXECUTE IMMEDIATE 'create table cindy_4711_5c_e_1st as

with v1 as (
select distinct t2.*,
t1.concept_cd, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
t5.pat_enc_csn_id, t5.contact_date as d1,  t8.name as visit

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case5=''5d''

inner join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

inner join cindy_4711_5c_e_3rd t6
on t2.pat_id=t6.pat_id

inner join cindy_ZC_DISP_ENC_TYPE_visit t8
on t5.ENC_TYPE_C=t8.DISP_ENC_TYPE_C

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')

)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d1, pat_enc_csn_id
)  as rn2
FROM v1 )t
Where rn2=1) t1
';

----------------------------------------
EXECUTE IMMEDIATE 'drop table   cindy_4711_5c_f ';---get the latest
EXECUTE IMMEDIATE 'create table cindy_4711_5c_f as

with v1 as (
select distinct t2.*,
t1.concept_cd, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
COALESCE(t5.contact_date,t1.start_date) as d4

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case5=''5e''

left join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')


)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d4 desc
)  as rn2
FROM v1 )t
Where rn2=1) t1
';
-----------------------------
EXECUTE IMMEDIATE 'drop table    CINDY_4711_5c ';
EXECUTE IMMEDIATE 'create table  CINDY_4711_5c as

with v1 as
(
select distinct t1.pat_id

from cindy_4711_5c_e_1st t1

inner join  CINDY_4711_5c_f t2---latest
on t1.pat_id=t2.pat_id
and t2.d4 >= t1.d1
)
-------------------
select distinct t1.*

from   cindy_4711_5c_e_3rd_detail t1
left join v1
on t1.pat_id=v1.pat_id
where v1.pat_id is null
';
------case4---------------------------------------------
#To find case4a, look for case5d
#To find case4b, look for case5e

EXECUTE IMMEDIATE 'drop table    cindy_4711_5d_e_4th ';--get the 4th
EXECUTE IMMEDIATE 'create table  cindy_4711_5d_e_4th as

with v1 as (
select distinct t2.*,
t5.pat_enc_csn_id, t5.contact_date as d3,
t8.name as visit3

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case5=''5d''

inner join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM


inner join cindy_ZC_DISP_ENC_TYPE_visit t8
on t5.ENC_TYPE_C=t8.DISP_ENC_TYPE_C

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')

)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d3, pat_enc_csn_id
)  as rn2
FROM v1 )t
Where rn2=4) t1
';

---------------------------------

EXECUTE IMMEDIATE 'drop table      cindy_4711_5d_e_4th_detail  ';---get the 4th
EXECUTE IMMEDIATE 'create table    cindy_4711_5d_e_4th_detail as

with v1 as (
select distinct t2.*,
t1.concept_cd as concept3, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
t5.pat_enc_csn_id, t5.contact_date as d3,  t8.name as visit3

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case5=''5d''

inner join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

inner join cindy_4711_5d_e_4th t6
on t5.PAT_ENC_CSN_ID=t6.PAT_ENC_CSN_ID

inner join cindy_ZC_DISP_ENC_TYPE_visit t8
on t5.ENC_TYPE_C=t8.DISP_ENC_TYPE_C

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')

)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by concept3
)  as rn3
FROM v1 )t
Where rn3=1) t1
';

---------------------------------
EXECUTE IMMEDIATE 'drop table     cindy_4711_5d_e_1st ';--get the 1st
EXECUTE IMMEDIATE 'create table   cindy_4711_5d_e_1st as


with v1 as (
select distinct t2.*,
t1.concept_cd, t3.name_char,  t1.SOURCESYSTEM_CD, t4.*,
t5.pat_enc_csn_id, t5.contact_date as d1,  t8.name as visit

from stageuser.observation_fact t1

inner join cindy_4711_1_mrn t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case5=''5d''

inner join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

inner join cindy_4711_5d_e_4th t6
on t2.pat_id=t6.pat_id

inner join cindy_ZC_DISP_ENC_TYPE_visit t8
on t5.ENC_TYPE_C=t8.DISP_ENC_TYPE_C

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')

)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d1,pat_enc_csn_id
)  as rn2
FROM v1 )t
Where rn2=1) t1

';

-----------------------------
EXECUTE IMMEDIATE 'drop table     CINDY_4711_5d ';
EXECUTE IMMEDIATE 'create table   CINDY_4711_5d as

with v1 as
(
select distinct t1.pat_id

from cindy_4711_5d_e_1st t1

inner join  CINDY_4711_5c_f t2---latest
on t1.pat_id=t2.pat_id
and t2.d4 >= t1.d1
)
-------------------
select distinct t1.*

from  cindy_4711_5d_e_4th_detail t1
left join v1
on t1.pat_id=v1.pat_id
where v1.pat_id is null
';
------------------

EXECUTE IMMEDIATE 'drop table     CINDY_4711_5 ';
EXECUTE IMMEDIATE 'create table   CINDY_4711_5 as


select distinct t1.*, t2.d3 as d4,t2.concept3 as concept4, t2.visit3 as visit4
 from CINDY_4711_5c t1
left join  CINDY_4711_5d t2
on t1.mrn=t2.mrn
';

--------------------------- case 6 
#controls

EXECUTE IMMEDIATE 'drop table     CINDY_4711_c6 ';---to get non_case pat
EXECUTE IMMEDIATE 'create table   CINDY_4711_c6 as


select distinct t0.* from CINDY_4711_1_MRN t0
left join CINDY_4711_c1  t1
on t0.mrn=t1.mrn

left join CINDY_4711_c2  t2
on t0.mrn=t2.mrn

left join CINDY_4711_c3  t3
on t0.mrn=t3.mrn

left join CINDY_4711_5  t5
on t0.mrn=t5.mrn

where t0.pat_id is not null
and (t1.mrn is null and t2.mrn is null and t3.mrn is null and t5.mrn is null)
';

------------------------------
EXECUTE IMMEDIATE 'drop table     cindy_4711_c6a_latest';---include
EXECUTE IMMEDIATE 'create table   cindy_4711_c6a_latest as

with v1 as (
select distinct t2.*,   t1.SOURCESYSTEM_CD,
t4.*,
COALESCE(t5.contact_date,t1.start_date) as d1

from stageuser.observation_fact t1

inner join cindy_4711_c6 t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case6=''6a''-------------------

left join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d1 desc
)  as rn2
FROM v1 )t
Where rn2=1) t1
';

-------------------------------------
EXECUTE IMMEDIATE 'drop table   cindy_4711_c6a_latest_2 ';
EXECUTE IMMEDIATE 'create table cindy_4711_c6a_latest_2 as
with v1 as (
select distinct ENROLLED, mrn, pat_id, CONCEPT_CODE, CONCEPT_NAME, D1
from cindy_4711_c6a_latest
union 
select distinct t1.ENROLLED, t1.mrn, t1.pat_id, t1.CPT_CODE, t1.DESCRIPTION, t1.ORDERING_DATE
from cindy_4711_0_76140 t1
inner join cindy_4711_c6 t2
on  t1.patient_num=t2.patient_num
)
------------------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d1 desc
)  as rn2
FROM v1 )t
Where rn2=1) t1
';

--------------------------------------

EXECUTE IMMEDIATE 'drop table    cindy_4711_c6b_1st ';--exclude
EXECUTE IMMEDIATE 'create table  cindy_4711_c6b_1st as


with v1 as (
select distinct t2.*,   t1.SOURCESYSTEM_CD,
t4.*,
COALESCE(t5.contact_date,t1.start_date) as d2

from stageuser.observation_fact t1

inner join cindy_4711_c6 t2
on  t1.patient_num=t2.patient_num

inner join i2b2demodatautcris.concept_dimension t3
on  t1.concept_cd=t3.concept_cd

inner join CINDY_4711_0_CODE t4
on t3.concept_cd= t4.VOCABULARY_ID || t4.CONCEPT_CODE
and t4.case6=''6b''---------------

left join sourceuser.epic_pat_enc t5
on t2.pat_id=t5.pat_id
and ''14''||LPAD(t5.PAT_ENC_CSN_ID, 13, ''0'')= t1.ENCOUNTER_NUM

where t1.modifier_cd not in (''DX|PROB:DELETED'', ''DX|PROB:RESOLVED'', ''DX|HISTORY'')
)
-------------------------
SELECT  distinct t1.*
FROM (select t.* from (  SELECT distinct v1.*,
ROW_NUMBER() OVER (
PARTITION by pat_id
ORDER by d2
)  as rn2
FROM v1 )t
Where rn2=1) t1
';

------------------------
EXECUTE IMMEDIATE 'drop table    cindy_4711_c6c ';
EXECUTE IMMEDIATE 'create table  cindy_4711_c6c as


with v1 as
(
select distinct t1.pat_id

from CINDY_4711_C6a_latest_2 t1

inner join  CINDY_4711_c6b_1st t2
on t1.pat_id=t2.pat_id
and t2.d2 >t1.d1
)
-------------------
select distinct t1.*

from CINDY_4711_C6a_latest_2 t1
left join v1
on t1.pat_id=v1.pat_id
where v1.pat_id is null
';



end;
/
