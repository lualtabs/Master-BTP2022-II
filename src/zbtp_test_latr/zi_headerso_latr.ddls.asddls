@AbapCatalog.sqlViewName: 'ZV_HEADER_LATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Interface Header Sale Order'
define root view zi_headerso_latr
  as select from zheaderso_latr as Header
  composition [0..*] of zi_itemsso_latr as _Items
{
  key id           as Id,
      email        as Email,
      firstname    as Firstname,
      lastname     as Lastname,
      country      as Country,
      createon     as Createon,
      deliverydate as Deliverydate,
      orderstatus  as Orderstatus,
      imageurl     as Imageurl,
      _Items
}
