@AbapCatalog.sqlViewName: 'ZV_BOOKSUP_LATR'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Booinkg Supplement'
define view ZI_BOOKSUPPL_LATR
  as select from ztb_booksup_latr as BookingSupplement
  association to parent ZI_BOOKING_LATR as _Booking on  $projection.TravelId  = _Booking.TravelId
                                                    and $projection.BookingId = _Booking.BookingId
  association [1..1] to ZI_TRAVEL_LATR as _Travel on $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement as _Product on $projection.SupplementId = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementId = _SupplementText.SupplementID                                                  
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
//  key travel_id,
//  key booking_id,
//  key booking_supplement_id,

      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      price                 as Price,
      @Semantics.currencyCode: true
      currency_code         as CurrencyCode,
      last_changed_at       as LastchangeAt,
      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
