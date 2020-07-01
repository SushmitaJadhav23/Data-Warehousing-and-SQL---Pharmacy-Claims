DROP DATABASE IF EXISTS Final_Project;
create database Final_Project;

use Final_Project;

#import 1 fact and 4 dimension tables
select * from fact_table_pharma; #11 rows returned
select * from dim_drugbrand; #2 rows returned
select * from dim_drugform; #3 rows returned
select * from dim_drugname; #4 rows returned
select * from dim_patient; #4 rows returned

#-----------------------------Adding primary key ----------------------------------------#
#Surrogate key as Primary key-

Alter table fact_table_pharma
ADD cost_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY; #created a surrogate key(cost_id) for fact table 


ALTER TABLE dim_patient
ADD PRIMARY KEY (member_id); #Adding Natural key as Primary key


ALTER TABLE dim_drugname
ADD PRIMARY KEY (drug_ndc); #Adding Natural key as Primary key


ALTER TABLE dim_drugform
MODIFY drug_form_code CHAR(2); #changing data type to char(2) as given in dataset

ALTER TABLE dim_drugform
ADD PRIMARY KEY (drug_form_code); #Adding Natural key as Primary key 


ALTER TABLE dim_drugbrand
ADD PRIMARY KEY (drug_brand_generic_code); #Adding Natural key as Primary key 

#.....................................Task to add Foreign Keys.............................................#  

ALTER TABLE  Fact_table_pharma
ADD FOREIGN KEY drug_fk(drug_ndc)
REFERENCES Dim_drugname(drug_ndc)
ON DELETE SET NULL
ON UPDATE RESTRICT;

#Foreign Keys -  

ALTER TABLE  Fact_table_pharma
ADD FOREIGN KEY member_fk(member_id)
REFERENCES Dim_patient(member_id)
ON DELETE SET NULL
ON UPDATE RESTRICT;

#Foreign Keys -  

ALTER TABLE  Dim_drugname
MODIFY drug_form_code CHAR(2);

ALTER TABLE  Dim_drugname
ADD FOREIGN KEY Fcode_fk(drug_form_code)
REFERENCES Dim_drugform(drug_form_code)
ON DELETE SET NULL
ON UPDATE RESTRICT;

#Foreign Keys -  

ALTER TABLE  Dim_drugname
ADD FOREIGN KEY brand_fk(drug_brand_generic_code)
REFERENCES Dim_drugbrand(drug_brand_generic_code)
ON DELETE SET NULL
ON UPDATE RESTRICT;

#Q1] Number of prescriptions grouped by drug name

Select drug_name, Count(*) as Prescription_Count
from Dim_drugname a inner Join Fact_table_pharma b 
on a.drug_ndc = b.drug_ndc 
group by drug_name 
order by count(*);


#Q2] Total prescriptions, unique members, total copay & insurance paid $$, for members either ‘age 65+’ or ’ < 65’

SELECT 
    COUNT(a.drug_ndc) AS Total_Prescription,
    COUNT(DISTINCT a.member_id) AS Unique_distinct_patients,
    SUM(a.copay) AS Total_copay,
    SUM(a.insurancepaid) AS Total_insurance_paid,
    CASE
        WHEN b.member_age > 65 THEN 'Age Over 65'
        WHEN b.member_age < 65 THEN 'Age below 65'
    END AS Age_group
from
    fact_table_pharma a
        LEFT JOIN
    Dim_patient b ON a.member_id = b.member_id
GROUP BY Age_group;


#Q3] Amount paid by the insurance for the most recent prescription fill date.

create table Insurance as
select a.member_id, a.fill_date, a.insurancepaid, b.member_first_name, b.member_last_name, c.drug_name,   
row_number() over (partition by a.member_id order by a.member_id, a.fill_date desc) as flag
from Fact_table_pharma a left join Dim_patient b on a.member_id = b.member_id 
left join Dim_drugname c on a.drug_ndc = c.drug_ndc;

SELECT 
    member_id,
    member_first_name,
    member_last_name,
    drug_name,
    fill_date,
    insurancepaid
from
    Insurance
Where flag = 1;



