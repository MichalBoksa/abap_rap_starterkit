@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Document header totals in EUR'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_ZCG_RAP_MBO_HEAD_SUM
  as select from ZI_ZCG_RAP_MBO_ITEM_EUR as Item
{
  key Item.HeaderId,

      Item.CurrencyEUR,

      @Semantics.amount.currencyCode: 'CurrencyEUR'
      sum( Item.ValueEUR ) as TotalValueEUR,

      cast(
        case
          when sum( Item.ValueEUR ) = 0   then 1
          when sum( Item.ValueEUR ) <= 100 then 2
          else 3
        end
        as abap.int1
      )                    as TotalCriticality
}
group by
  Item.HeaderId,
  Item.CurrencyEUR
