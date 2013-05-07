'use strict';

var OnTime = OnTime || {};

OnTime.AverageChart = function(options) {
  options = options || {};

  var viz = options.vizSelector,
      $el = $(viz),
      margins = options.margins || { top: 20, right: 20, bottom: 30, left: 40 },
      svg;


  this.draw = function(dataset) {

    var xLabels = dataset.map(function(d) {
      return d._id;
    }),
    xScale = d3.scale.ordinal().domain(xLabels).rangeRoundBands([0 , width()], .1);

    svg = d3.select(viz)
      .append('svg')
      .attr('width', width())
      .attr('height', height());

    svg.selectAll('rect')
      .data(dataset)
      .enter()
      .append('rect')
      .attr('x', function(d, i) {
        return xScale(i);
      })
      .attr('y', function(d) {
        return height() - d.avg_delay * 10;
      })
      .attr('width', function() {
        return xScale.rangeBand();
      })
      .attr('height', function(d) {
        return 10 * d.avg_delay;
      })
      .attr('class', 'bar');

    svg.selectAll('text')
      .data(dataset)
      .enter()
      .append('text')
      .attr('x', function(d, i) {
        return xScale(i) + (xScale.rangeBand() / 3);
      })
      .attr('y', function(d) {
        return height() - (10 * d.avg_delay) + 20;
      })
      .text(function(d) {
        return d._id;
      });
  }

  function init() {
    console.log('OnTime.AverageChart initialized');
  }

  function width() {
    return $el.width() - margins.left - margins.right;
  }

  function height() {
    return $el.height() - margins.top - margins.bottom;
  }

  init();
};
