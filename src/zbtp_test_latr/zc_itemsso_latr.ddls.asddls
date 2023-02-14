@EndUserText.label: 'Cunsumption - Items Sale Order'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity zc_itemsso_latr
  as projection on zi_itemsso_latr
{
  key Id,
      Name,
      Description,
      Releasedate,
      Discontinueddate,
      Price,
      Height,
      Width,
      Depth,
      Quantity,
      Unitofmeasure,
      /* Associations */
      _Header : redirected to parent zc_headerso_latr 
}
