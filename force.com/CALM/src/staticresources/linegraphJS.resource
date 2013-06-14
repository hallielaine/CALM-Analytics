function treatAsUTC(date) {
    var result = new Date(date);
    result.setMinutes(result.getMinutes() - result.getTimezoneOffset());
    return result;
}

function daysBetween(startDate, endDate) {
    var millisecondsPerDay = 24 * 60 * 60 * 1000;
    return (treatAsUTC(endDate) - treatAsUTC(startDate)) / millisecondsPerDay;
}

function isMonthly(start, end) {
   var startDate = new Date(start);
   var today = new Date();
	var range = new Date();
	range.setDate(today.getDate()-61);
	
	startDate.setHours(0);
	startDate.setMinutes(0);
	startDate.setSeconds(0);
	startDate.setMilliseconds(0);
	
	range.setHours(0);
   range.setMinutes(0);
   range.setSeconds(0);
   range.setMilliseconds(0);
	
	return !((startDate >= range) && ((daysBetween(start, end)+1) <= 60))
}

function drawLineGraph(title, subtitle, chartSeries, start, end)
{
   var seriesColors = new Array();
   seriesColors.push('#1c8fc7');
   seriesColors.push('#de4001');
   
   var minTickIntervalValue = 24 * 3600 * 1000; // one day
   
   if (isMonthly(start, end)) {
       minTickIntervalValue = minTickIntervalValue * 28; // one month
   }
   
   $(document).ready(function()
   {
       var chart;
       chart = new Highcharts.Chart(
       {
           chart:
           {
               renderTo: 'container',
               type: 'line',
               zoomType: 'x'
           },
           title:
           {
               text: title
           },
           subtitle:
           {
               text: subtitle
           },
           credits:
           {
               enabled: false
           },
           xAxis:
           {
               startOnTick: false,
               endOnTick: false,
               showLastLabel: true,
               minPadding: 0.02,
               maxPadding:0.02,
               type: 'datetime',
               dateTimeLabelFormats:
               {
                   day: '%b %e'
               },
               minTickInterval: minTickIntervalValue,
               tickPixelInterval: 50,
               labels:
               {
                   rotation: -45,
                   align: 'right'
               }
           },
           yAxis:
           {
               title:
               {
                   text: null
               },
               min: 0,
               allowDecimals: false
           },
           tooltip:
           {
               formatter: function()
               {
                   return '<b>Occurrences</b><br/>' +
                           moment.utc(this.x).format('ddd, MMM DD') + ': ' + this.y;
               }
           },
           legend:
           {
               enabled: true
           },
           plotOptions:
           {
               scatter:
               {
                   marker:
                   {
                       radius: 5,
                       states:
                       {
                           hover:
                           {
                               enabled: true,
                               lineColor: 'rgb(100,100,100)'
                           }
                       }
                   },
                   states:
                   {
                       hover:
                       {
                           marker:
                           {
                               enabled: false
                           }
                       }
                   }
               }
           },
           series: chartSeries,
           colors: seriesColors
       });
   });
}
