// this doesn't really do anything 
// because it doesn't load properly
// it's supposed to customize the look
// of the range limit plot

//= require 'jquery'


$('.blacklight-pub_date').data('plot-config', { 
  selection: { color: '#C0FF83' }, 
  colors: ['#ffffff'], 
  series: { lines: { fillColor: 'rgba(255,255,255, 0.5)' }}, 
  grid: { color: '#aaaaaa', tickColor: '#aaaaaa', borderWidth: 0 }  
});