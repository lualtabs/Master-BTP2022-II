@EndUserText.label: 'Cunsumption - Header Sale Order'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity zc_headerso_latr
  as projection on zi_headerso_latr
{
  key Id,
      Email,
      Firstname,
      Lastname,
      Country,
      Createon,
      Deliverydate,
      Orderstatus,
      Imageurl,
      /* Associations */
      _Items : redirected to composition child zc_itemsso_latr
}
