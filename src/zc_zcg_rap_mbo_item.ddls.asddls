@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection CDS view for Items entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_ZCG_RAP_MBO_ITEM
  as projection on ZI_ZCG_RAP_mbo_ITEM as Items
{
  key Uuid,
      HeaderId,
      @Search.defaultSearchElement: true
      DocumentNumber,
      ItemNumber,
      @Consumption.valueHelpDefinition: [{
      entity: {
        name: 'ZI_ZCG_RAP_MBO_COMP',
        element: 'Uuid'
      },
      useForValidation: true
      }]
      ComponentId,
      @ObjectModel.text.element: ['MaterialName']
      @Search.defaultSearchElement: true
      _Component.Matnr as MaterialNumber,

      @Search.defaultSearchElement: true
      _Component.Maktx as MaterialName,
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      Quantity,
      @Consumption.valueHelpDefinition: [{
      entity: {
      name: 'I_UnitOfMeasure',
      element: 'UnitOfMeasure'
      }
      }]
      UnitOfMeasure,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      _Component.Price as ComponentPrice,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Value,

      CurrencyCode,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,


      /* Associations */
      _Component,
      _Header : redirected to parent ZC_ZCG_RAP_MBO_HEAD,
      _UOM
}
