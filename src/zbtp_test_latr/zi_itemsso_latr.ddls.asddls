@AbapCatalog.sqlViewName: 'ZV_ITEMSSO_LATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Interface Items Sale Order'
define view zi_itemsso_latr
  as select from zitemsso_latr as items
{
  id               as Id,
  name             as Name,
  description      as Description,
  releasedate      as Releasedate,
  discontinueddate as Discontinueddate,
  price            as Price,
  height           as Height,
  width            as Width,
  depth            as Depth,
  quantity         as Quantity,
  unitofmeasure    as Unitofmeasure
}
