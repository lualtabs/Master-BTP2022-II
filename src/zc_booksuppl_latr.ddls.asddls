@EndUserText.label: 'Consumption - Booinkg Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPPL_LATR
  as projection on ZI_BOOKSUPPL_LATR
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      SupplementId,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      Price,
      @Semantics.currencyCode: true
      CurrencyCode,
      LastchangeAt,
      /* Associations */
      _Travel: redirected to ZC_TRAVEL_LATR,
      _Booking: redirected to parent ZC_BOOKING_LATR,
      _Product,
      _SupplementText
}
