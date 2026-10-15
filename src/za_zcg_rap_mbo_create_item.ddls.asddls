@EndUserText.label: 'Abstract Entity Create Items'
define abstract entity ZA_ZCG_RAP_MBO_CREATE_ITEM
{
    @EndUserText.label: 'Component'
    @Consumption.valueHelpDefinition: [{  
        entity: {
        name: 'ZC_ZCG_RAP_MBO_COMP',
        element: 'Uuid'
        }
    }]
    ComponentId: sysuuid_x16;
    
    @EndUserText.label: 'Quantity'
    Quantity: zcg_rap_mbo_quant;
    
}
