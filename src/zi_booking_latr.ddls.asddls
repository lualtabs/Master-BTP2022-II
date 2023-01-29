@AbapCatalog.sqlViewName: 'ZV_BOOKING_LATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Booking'
define view ZI_BOOKING_LATR
  as select from ztb_booking_latr as BOOKING
  composition [0..*] of ZI_BOOKSUPPL_LATR as _BookingSupplement
  association        to parent ZI_TRAVEL_LATR    as _Travel on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Customer   as _Customer      on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier    as _Carrier       on  $projection.CarrierId = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection as _Connection    on  $projection.CarrierId    = _Connection.AirlineID
                                                            and $projection.ConnectionId = _Connection.ConnectionID
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode' 
      flight_price    as FlightPrice,
      @Semantics.currencyCode: true
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      last_changed_at as LastChangedAt,
      _Travel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection
}
