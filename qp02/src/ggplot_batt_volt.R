# script to plot battery voltage at queensland sites.

# excluding all columns excet batt voltage
# using den.qld
  den.qld.batt <- den.qld[ , c('TIMESTAMP', 'batt_volt_Avg.Brib', 'batt_volt_Avg.Beer')]
  # stack with reshape
  require(reshape2)
  den.qld.batt <- melt(den.qld.batt, id = 'TIMESTAMP')
  detach(package:reshape2)
  
  # plot with ggplot  
  ggplot(data=den.qld.batt) + 
    geom_point(aes(x=TIMESTAMP, y = value, colour = variable)) +
    scale_y_continuous('Battery voltage (V)')
  ggsave(file.path('graphs', 'Rplot23.pdf'))


# using output.list
den.Brib <- output.list[[1]]
den.Beer <- output.list[[2]]

den.qld.batt <- den.Brib[ , c('TIMESTAMP', 'batt_volt_Avg.Brib')]
