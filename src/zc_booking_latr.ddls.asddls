@EndUserText.label: 'Consumption - Booinkg'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_LATR
  as projection on ZI_BOOKING_LATR
{
  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      _Carrier.Name as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      BookingStatus,
      LastChangedAt,
      /* Associations */
      _Travel: redirected to parent ZC_TRAVEL_LATR,
      _BookingSupplement: redirected to composition child ZC_BOOKSUPPL_LATR,
      _Carrier,
      _Connection,
      _Customer
}
 