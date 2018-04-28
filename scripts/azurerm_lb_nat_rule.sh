tfp="azurerm_lb_nat_rule"
prefixa="lbnr"
if [ "$1" != "" ]; then
    rgsource=$1
else
    echo -n "Enter name of Resource Group [$rgsource] > "
    read response
    if [ -n "$response" ]; then
        rgsource=$response
    fi
fi
azr=`az network lb list -g $rgsource`
count=`echo $azr | jq '. | length'`
if [ "$count" -gt "0" ]; then
    count=`expr $count - 1`
    for i in `seq 0 $count`; do
        beap=`echo $azr | jq ".[(${i})].inboundNatRules"`

      
        
        icount=`echo $beap | jq '. | length'`
        if [ "$icount" -gt "0" ]; then
            icount=`expr $icount - 1`
            for j in `seq 0 $icount`; do
                
                name=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].name" | cut -d'/' -f11 | tr -d '"'`
                id=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].id" | tr -d '"'`
                rg=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].resourceGroup" | tr -d '"'`
                prefix=`printf "%s__%s" $prefixa $rg` 
                
                lbrg=`echo $azr | jq ".[(${i})].id" | cut -d'/' -f5 | tr -d '"'`
                lbname=`echo $azr | jq ".[(${i})].id" | cut -d'/' -f9 | tr -d '"'`

                fep=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].frontendPort" | tr -d '"'`
                bep=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].backendPort" | tr -d '"'`
                proto=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].protocol" | tr -d '"'`
                feipc=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].frontendIpConfiguration.id" | cut -d'/' -f11 | tr -d '"'`
                enfip=`echo $azr | jq ".[(${i})].inboundNatRules[(${j})].enableFloatingIp" | cut -d'/' -f11 | tr -d '"'`

                
                printf "resource \"%s\" \"%s__%s\" {\n" $tfp $rg $name > $prefix-$name.tf
                printf "\t\t name = \"%s\" \n"  $name >> $prefix-$name.tf
                printf "\t\t resource_group_name = \"%s\" \n"  $rg >> $prefix-$name.tf
                printf "\t\t loadbalancer_id = \"\${azurerm_lb.%s__%s.id}\"\n" $lbrg $lbname >> $prefix-$name.tf
                printf "\t\t frontend_ip_configuration_name = \"%s\" \n"  $feipc >> $prefix-$name.tf
                printf "\t\t protocol = \"%s\" \n"  $proto >> $prefix-$name.tf
                printf "\t\t backend_port = \"%s\" \n"  $bep >> $prefix-$name.tf
                printf "\t\t frontend_port = \"%s\" \n"  $fep >> $prefix-$name.tf
                if [ "$enfip" != "null" ]; then
                printf "\t\t enable_floating_ip = \"%s\" \n"  $enfip >> $prefix-$name.tf
                fi
                printf "}\n" >> $prefix-$name.tf
        #
                cat $prefix-$name.tf
                statecomm=`printf "terraform state rm %s.%s__%s" $tfp $rg $name`
                echo $statecomm >> tf-staterm.sh
                eval $statecomm
                evalcomm=`printf "terraform import %s.%s__%s %s" $tfp $rg $name $id`
                echo $evalcomm >> tf-stateimp.sh
                eval $evalcomm




        #

        done
        fi

        


 
    done
fi
