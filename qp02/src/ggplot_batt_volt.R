# script to plot battery voltage at queensland sites.

# excluding all columns excet batt voltage
den.qld.batt <- den.qld[ , c('TIMESTAMP', 'batt_volt_Avg.Brib', 'batt_volt_Avg.Beer')]

# stack with reshape
require(reshape2)
den.qld.batt <- melt(den.qld.batt, id = 'TIMESTAMP')
detach(package:reshape2)

# ploth with ggplot

ggplot(data=den.qld.batt) + geom_point(aes(x=TIMESTAMP, y = value))
