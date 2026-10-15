@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection CDS view Components entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_ZCG_RAP_mbo_COMP
  provider contract transactional_query
  as projection on ZI_ZCG_RAP_mbo_COMP
{
      @EndUserText.label: 'ComponentID'
  key Uuid,
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Maktx']
      @EndUserText.label: 'Component number'
      Matnr,
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Component name'
      Maktx,
      @EndUserText.label: 'Component price'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      @ObjectModel.text.element: ['AltCurrencyKey']
      @EndUserText.label: 'Currency'
      CurrencyCode,
      _Currency.AlternativeCurrencyKey as AltCurrencyKey,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_UnitOfMeasure',
                                                     element: 'UnitOfMeasure' } }]
      UnitOfMeasure,
      @EndUserText.label: 'Created by'
      CreatedBy,
      @EndUserText.label: 'Created at'
      CreatedAt,
      @EndUserText.label: 'Last changed by'
      LastChangedBy,
      @EndUserText.label: 'Last changed at'
      LastChangedAt,

      LocalLastchangedAt,
      /* Associations */
      _Currency,
      _UOM
}
