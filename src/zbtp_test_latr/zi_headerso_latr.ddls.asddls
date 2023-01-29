@AbapCatalog.sqlViewName: 'ZV_HEADERSO_LATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Interface Header Sale Order'
define view zi_headerso_latr
  as select from zheaderso_latr as header
{
  key id           as Id,
  key email        as Email,
      firstname    as Firstname,
      lastname     as Lastname,
      country      as Country,
      createon     as Createon,
      deliverydate as Deliverydate,
      orderstatus  as Orderstatus,
      imageurl     as Imageurl
}
