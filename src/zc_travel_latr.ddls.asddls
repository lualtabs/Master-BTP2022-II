@EndUserText.label: 'Consumption Travel View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_LATR
  as projection on ZI_TRAVEL_LATR
{
  key     TravelId,
          AgencyId,
          CustomerId,
          BeginDate,
          EndDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          BookingFee,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          TotalPrice,
          @Semantics.currencyCode: true
          CurrencyCode,
          Description,
          OverallStatus,
          LastChangedAt,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_LATR'
  virtual DiscountPrice : /dmo/total_price,

          /* Associations */
          _Agency,
          _Booking : redirected to composition child ZC_BOOKING_LATR,
          _Currency,
          _Customer
}
