@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection CDS view for HEAD entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['DocumentNumber']
define root view entity ZC_ZCG_RAP_MBO_HEAD
  provider contract transactional_query
  as projection on ZI_ZCG_RAP_mbo_HEAD
{
  key     Uuid,
          DocumentNumber,
          _Text.Description     as Description : localized,
          CustomerId,
          _Customer.Title       as CustomerTitle,
          _Customer.FirstName   as CustomerFirstName,
          _Customer.LastName    as CustomerLastName,
          _Customer.Street      as CustomerStreet,
          _Customer.PostalCode  as CustomerPostalCode,
          _Customer.City        as CustomerCity,
          _Customer.CountryCode as CustomerCountryCode,
          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,
          LocalLastchangedAt,
          CurrencyEUR,

          @Semantics.amount.currencyCode: 'CurrencyEUR'
          TotalValueEUR,

          TotalCriticality,

          @EndUserText.label: 'Total value EUR - virtual'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_RAP_MBO_HEAD_VE'
          @Semantics.amount.currencyCode: 'CurrencyEUR'
  virtual TotalValueVirtualEUR : abap.curr(23,2),
          /* Associations */
          _Customer,
          _Items : redirected to composition child ZC_ZCG_RAP_MBO_ITEM,
          _Text  : redirected to composition child ZC_ZCG_RAP_MBO_HEAD_TEX
}
