DEBUG = [];

var OnTime = OnTime || {};

var Util = Util || {};

OnTime._airlines = undefined;

OnTime.airlines = function(cb) {
  if (OnTime._airlines === undefined) {
    $.get(api.airlines, function(response) {
      OnTime._airlines = response;
      if (cb) cb(OnTime._airlines);
    });
  }
  else {
    return OnTime._airlines;
  }
}

OnTime.init = function(options) {
  var api = options.api,
      that = this;

  this.averagePage = undefined;

  function init() {
    console.log('Hello, human. Loc is a cool guy. I think you\'ll like him!');

    that.averagePage = new OnTime.AvgForAirlines({ url: api.delays });

    $('a').on('click', function() {
      window.location.hash = this.hash;
    });

    showFromLocationHash();
    console.log('Initialized OnTime page');
  }

  function showFromLocationHash() {
    var hash = window.location.hash;
    hash && $('a[href=' + hash + ']').trigger('click');
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
      if (seconds === 90) {
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

OnTime.Alert = {
  $error: $('#alert'),

  $info: $('#info'),

  error: function(cb) {
    var e = this.$error,
      msg = e.find('.msg');
    msg.empty();
    e.show();
    if (cb) cb(msg);
  },

  info: function(cb) {
    var i = this.$info,
      msg = i.find('.msg');
    msg.empty();
    i.show();
    if (cb) cb(msg);
  }
};

OnTime.AvgForAirlines = function(options) {
  var $el = $('#average-page'),
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

    OnTime.Indicator.start();

    $.ajax({
      url: url,
      cache: true
    })
      .success(function(response) {
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
        OnTime.Alert.error(function($el) {
          $el.text('Error while requesting data');
        });
      });
  }

  function init() {
    $('a[href=#average-page]').click(function() {
      that.show();
    });


    OnTime.airlines(function(airlines) {
      var $legendTbody = $('#legend tbody');
      $legendTbody.empty();
      for (var a in airlines) {
        var row = $('<tr></tr>'),
          code = $('<td></td>').text(a),
          airline = $('<td></td>').text(airlines[a]);

        row.append(code);
        row.append(airline);
        $legendTbody.append(row);
      }
    });



    chart = new OnTime.AverageChart({
      vizSelector: '#average-delay-viz'
    });

    console.log('Initialized OnTime.AvgForAirlines')
  }

  init();

  return this;
};
