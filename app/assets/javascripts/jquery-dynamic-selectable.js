(function() {
  var DynamicSelectable;

  $.fn.extend({
    dynamicSelectable: function() {
      return $(this).each(function(i, el) {
        return new DynamicSelectable($(el));
      });
    }
  });

  DynamicSelectable = (function() {
    function DynamicSelectable($select) {
      this.init($select);
    }

    DynamicSelectable.prototype.init = function($select) {
      this.urlTemplate = $select.data('dynamicSelectableUrl');
      this.$targetSelect = $($select.data('dynamicSelectableTarget'));
      return $select.on('change', (function(_this) {
        return function() {
          $('#dynamic_selectable_button').addClass("disabled");
          var url;
          _this.clearTarget();
          url = _this.constructUrl($select.val());
          if (url) {
            return $.getJSON(url, function(data) {
              $.each(data, function(index, el) {
                return _this.$targetSelect.append("<option value='" + el.id + "'>" + el.name + "</option>");
              });
              return _this.reinitializeTarget();
            });
          } else {
            return _this.reinitializeTarget();
          }
        };
      })(this));
    };

    DynamicSelectable.prototype.reinitializeTarget = function() {
      $('#dynamic_selectable_button').removeClass("disabled");
      return this.$targetSelect.trigger("change");
    };

    DynamicSelectable.prototype.clearTarget = function() {
      return this.$targetSelect.html('');
    };

    DynamicSelectable.prototype.constructUrl = function(id) {
      if (id && id !== '') {
        return this.urlTemplate.replace(/:.+_id/, id);
      }
    };

    return DynamicSelectable;

  })();

}).call(this);