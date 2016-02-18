Flashcards = {
  
  answerButtonClasses: "p, b",
  openallButtonClasses: "p, .openall",
  baseClass: ".flashcards",

  setupAnswerButtonListeners: function() {
      var $base = $(this.baseClass)
      var $answerButton = $("<button class='answer-button'>answer</button>")
      // debugger
      var $togglers = $base.find(this.answerButtonClasses).hide().before($answerButton)
      $(".answer-button").before($("<br>")).after($("<br>"))
      $base.find(".answer-button").on("click", this.togglerClicked)  
  },

  togglerClicked: function(e){
      // debugger
      var $toggler = $(e.currentTarget).nextAll(Flashcards.answerButtonClasses).first()
      if ($toggler.hasClass("visible")) {
          // debugger
          $toggler.hide().removeClass("visible")
      } else {
          // debugger
          $toggler.show().addClass("visible")
      }
      e.preventDefault()
      return false
  },

  openallClicked: function(e){
      $(e.preventDefault())
      var $toggler = $(e.currentTarget).parent().children(Flashcards.answerButtonClasses)
      if ($toggler.hasClass("visible")) {
          // debugger
          $toggler.hide()
          $toggler.removeClass("visible")
      } else {
          // debugger
          $toggler.addClass("visible")
          $toggler.show()
      }
  },

  setupOpenallButtonListeners: function () {
    var $base = $(this.baseClass)
    var $openallButton = $("<button class='openall-button'>openall</button>")
    var $openall = $(this.openallButtonClasses).prepend($openallButton)
    $base.find(".openall-button").on("click", this.openallClicked)
  },

  begin: function() {
    this.setupAnswerButtonListeners()
    this.setupOpenallButtonListeners()
  }
}