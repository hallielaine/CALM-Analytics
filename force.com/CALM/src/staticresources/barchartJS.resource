function isAndroid()
{
	var ua = navigator.userAgent.toLowerCase();
	var isAndroid = ua.indexOf("mobile");
	var isTablet = ua.indexOf("android");
	return isAndroid >= 0 || isTablet >= 0;
}

function formatLabels(labels) {
	var formattedLabels = new Array();

	$.each(labels, function(index, elem) { 
	
		var div = document.createElement('div');
		div.innerHTML = elem;
		var decodedElem = div.firstChild.nodeValue;
		
		if (isAndroid()) {
			if (decodedElem.length > 8) {
				var temp = decodedElem.substring(0, 8) + "...";
				formattedLabels.push(temp);
			}
			else {
				formattedLabels.push(decodedElem);
			}
		}
		else {
			formattedLabels.push(decodedElem);
		}
	});
	
	return formattedLabels;
}

function drawBarGraph(title, subtitle, labels, values, clickHandler)
{

	var formattedLabels = formatLabels(labels);
   $(document).ready(function()
   {
       var chart;
       chart = new Highcharts.Chart(
       {
           chart:
           {
               renderTo: 'container',
               type: 'column'
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
               categories: formattedLabels,
               labels:
               {
                   rotation: -45,
                   align: 'right',
                   style:
                   {
                       fontSize: '13px',
                       fontFamily: 'Verdana, sans-serif'
                   }
               }
           },
           yAxis:
           {
               title:
               {
                   text: null
               },
               min: 0
           },
           tooltip:
           {
               formatter: function()
               {
                   return '' + this.x + ': ' + this.y;
               }
           },
           legend:
           {
               enabled: false
           },
           plotOptions:
           {
              column:
              {
                   colorByPoint: true,
                   cursor: 'pointer',
                   point:
					{
					    events:
					    {
					        click: clickHandler
					    }
					},
                   dataLabels:
                   {
                       enabled: true,
                       style:
                       {
                           fontWeight: 'bold'
                       },
                       formatter: function()
                       {
                           return this.y;
                       }
                   }
               }
           },
           series: [{ data: values }]
       });
   });
}
