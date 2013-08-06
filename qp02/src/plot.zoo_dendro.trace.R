# Script to plot most recent month, week and 3 days of data.

png(filename=paste0('graphs/', Sys.Date(), '_3days_', attr(target.data, 'label'), '.png'), 
    width = 14,
    height = 10,
    units = 'cm', 
    res = 300)
plot.zoo(first(last(den.qld.xts,'1 week'), '3 days'))
title(sub=attr(target.data, 'label'))
dev.off()

png(filename=paste0('graphs/', Sys.Date(), '_1week_', attr(target.data, 'label'), '.png'), 
    width = 14,
    height = 10,
    units = 'cm', 
    res = 300)
plot.zoo(last(den.qld.xts,'1 week'))
title(sub=attr(target.data, 'label'))
dev.off()

png(filename=paste0('graphs/', Sys.Date(), '_1month_', attr(target.data, 'label'), '.png'), 
    width = 14,
    height = 10,
    units = 'cm', 
    res = 300)
plot.zoo(last(den.qld.xts, '1 month'))
title(sub=attr(target.data, 'label'))
dev.off()