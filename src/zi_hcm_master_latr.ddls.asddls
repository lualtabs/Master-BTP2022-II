@AbapCatalog.sqlViewName: 'ZV_HCMASTER_LATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'HCM - Master'
define root view ZI_HCM_MASTER_LATR as select from zhc_master_latr as HCMMaster
{
key e_number,
e_name,
e_department,
status,
job_title,
start_date,
end_date,
email,
m_number,
m_name,
m_department,
crea_date_time,
crea_uname,
lchg_date_time,
lchg_uname
}
