@AbapCatalog.sqlViewName: 'ZV_ITEMS_LATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Interface Items Sale Order'
define view zi_itemsso_latr
  as select from zitemsso_latr as Items
  association to parent zi_headerso_latr as _Header on $projection.Id = _Header.Id
{
  key id               as Id,
      name             as Name,
      description      as Description,
      releasedate      as Releasedate,
      discontinueddate as Discontinueddate,
      price            as Price,
      @Semantics.quantity.unitOfMeasure : 'unitofmeasure'
      height           as Height,
      @Semantics.quantity.unitOfMeasure : 'unitofmeasure'
      width            as Width,
      depth            as Depth,
      quantity         as Quantity,
      @Semantics.unitOfMeasure : true
      unitofmeasure    as Unitofmeasure,
      _Header
}
