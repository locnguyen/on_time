'use strict';

var OnTime = OnTime || {};

OnTime.AverageChart = function(options) {
  options = options || {};

  var viz = options.vizSelector,
      $el = $(viz),
      margins = options.margins || { top: 20, right: 20, bottom: 30, left: 40 },
      padding = options.padding || 5,
      svg;


  this.draw = function(dataset) {
    var len = dataset.length;

    var xScale = d3.scale.ordinal().domain(d3.range(dataset));

    svg = d3.select(viz)
      .append('svg')
      .attr('width', width())
      .attr('height', height());

    svg.selectAll('rect')
      .data(dataset)
      .enter()
      .append('rect')
      .attr('x', function(d, i) {
        return i * (width() / len);
      })
      .attr('y', function(d) {
        return height() - d.avg_delay * 10;
      })
      .attr('width', function() {
        return width() / len - padding  ;
      })
      .attr('height', function(d, i) {
        return 10 * d.avg_delay;
      })
      .attr('class', 'bar');

    svg.selectAll('text')
      .data(dataset)
      .enter()
      .append('text')
      .attr('x', function(d, i) {
        return i * (width() / len);
      })
      .attr('y', function(d) {
        return height() - d.avg_delay * 10 + 15;
      })
      .text(function(d) {
        return d._id;
      });
  }

  function init() {

  }

  function width() {
    return $el.width() - margins.left - margins.right;
  }

  function height() {
    return $el.height() - margins.top - margins.bottom;
  }

  init();
};
