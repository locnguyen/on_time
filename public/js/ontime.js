DEBUG = [];

var OnTime = OnTime || {};

var Util = Util || {};

Util.hashVal = function() {
  return location.hash;
}

OnTime.init = function(options) {
  var api = options.api,
      that = this;

  this.averagePage = undefined;

  function init() {
    that.averagePage = new OnTime.AvgForAirlines({ url: api.delays });

    console.log('Initialized OnTime page');
  }

  init();

  return this;
};

OnTime.Indicator = {
  $el: $('#indicator'),

  $bar: $('#bar'),

  start: function() {
    var that = this;
    this.$bar.width('0%');
    this.$el.show();


    var seconds = 5;

    var intervalId = setInterval(function() {
      if (seconds >= 98) {
        clearInterval(intervalId);
        return;
      }

      that.$bar.width(seconds + '%');
      seconds++;
    }, 1000);
  },

  stop: function() {
    this.$bar.width('100%');
    this.$el.fadeOut();
  }
};

OnTime.AvgForAirlines = function(options) {
  var $el = $('#average-page'),
      $viz = $el.find('#average-delay-viz'),
      url = options.url || '',
      data = [],
      chart,
      that = this;

  this.show = function() {
    if (hasData()) {
      _show();
    }
    else {
      loadData(_show);
    }
  };

  function hasData() {
    return data.length > 0;
  }

  function _show() {
    chart.draw(data);
  }

  function loadData(callback) {
    if (url === '') return;

    // url = url + '?airlines=UA';

    OnTime.Indicator.start();

    $.get(url, function(response) {
      DEBUG = response;
      data = response;
      if (callback) {
        callback();
      }
    })
    .complete(function() {
        OnTime.Indicator.stop();
    })
    .fail(function() {
      $('#error').show().text('Error while requesting data');
    });
  }

  function init() {
    $('a[href=#average-page]').click(function() {
      that.show();
    });

    chart = new OnTime.AverageChart({
      vizSelector: '#average-delay-viz'
    });

    console.log('Initialized OnTime.AvgForAirlines')
  }

  init();

  return this;
};
