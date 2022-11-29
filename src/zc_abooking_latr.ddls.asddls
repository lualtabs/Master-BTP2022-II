@EndUserText.label: 'Consumption - Booinkg Approval'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_ABOOKING_LATR
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
      _Travel: redirected to parent ZC_ATRAVEL_LATR,
      _Customer,
      _Carrier
}
