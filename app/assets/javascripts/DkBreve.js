/* global $,window, jQuery, dkBreve, KbOSD */
window.dkBreve = (function (window, $, undefined) {
    'use strict';
    var DkBreve = function () {};

    DkBreve.prototype = {
        /**
         * Get current page in ocr pane
         */
        getOcrCurrentPage : function () {
            var ocrElem = $('.ocr'),
                ocrScrollTop = ocrElem[0].scrollTop,
                ocrScrollTopOffset = ocrScrollTop + 9, // Magic number 9 is 1 px less than the margin added when setting pages
                ocrBreaks = $('.pageBreak', ocrElem);

            // TODO: Optimization: Split on length so letters with more than 10 pages uses a binary search approach to figure out the correct page!
            var i = 0;
            if ($(ocrBreaks[0]).position().top + ocrScrollTopOffset > ocrScrollTop) {
                return 1; // user are before the very first pageBreak => page 1
            }
            while (i < ocrBreaks.length && $(ocrBreaks[i]).position().top + ocrScrollTopOffset <= ocrScrollTop) {
                i++;
            }
            return i + 1;
        },

        /**
         * Scroll to a (one-based) numbered page in the ocr
         * @param page
         */
        gotoOcrPage : function (page, skipAnimation) {
            var that = this,
                ocrElem = $('.ocr').first(),
                pageCount = $('.pageBreak', ocrElem).length + 1;
            if (page < 1 || page > pageCount) {
                throw('DkBreve.gotoOcrPage: page "' + page + '" out of bounds.');
            }
            if (that.animInProgress) {
                ocrElem.stop(true, true);
            }
            if (skipAnimation) {
                that.animInProgress = true;
                if (page === 1) {
                    ocrElem[0].scrollTop = 0;
                } else {
                    ocrElem[0].scrollTop = $($('.ocr .pageBreak')[page - 2]).position().top + $('.ocr')[0].scrollTop + 10;
                }
                setTimeout(function () {that.animInProgress = false;}, 0);
            } else {
                that.animInProgress = true;
                if (page === 1) {
                    ocrElem.animate({scrollTop: 0}, 500, 'swing', function () {
                        that.animInProgress = false;
                    }); // scroll to top of text
                } else {
                    ocrElem.animate({
                        scrollTop: $($('.ocr .pageBreak')[page - 2]).position().top + $('.ocr')[0].scrollTop + 10
                    }, 500, 'swing', function () {
                        that.animInProgress = false;
                    });
                }
            }
        },
        onOcrScroll : function () {
            var that = dkBreve;
            if (!that.animInProgress) {
                // this is a genuine scroll event, not something that origins from a kbOSD event
                var currentOcrPage = that.getOcrCurrentPage(),
                    kbosd = KbOSD.prototype.instances[0]; // The dkBreve object should have a kbosd property set to the KbOSD it uses!
                if (kbosd.getCurrentPage() !== currentOcrPage) {
                    that.scrollingInProgress = true;
                    kbosd.setCurrentPage(currentOcrPage, function () {
                        that.scrollingInProgress = false; // This is ALMOST enough ... but it
                    });
                }
            }
        },
        onFullScreen: function (e) {
            var that = dkBreve, // TODO: This is so cheating, but I only get the contentElement as scope. :-/
                fullScreen = e.detail.fullScreen;
            that.fullScreen = fullScreen;
            if (!fullScreen) {
                // just returned from fullscreen - scroll ocr pane accordingly
                that.gotoOcrPage(that.kbosd.getCurrentPage(), true);
            }
        },
        onDocumentReady: function () {
            // Collapse/Expand metadata column
            $('.collapseMetadata').click(function (e) {
                $('#letter_metadata_container').toggleClass('col-md-1 col-md-2');
                $('#letter_metadata_container').toggleClass('nometa');
                $('#letter_ocr_container').toggleClass('col-md-6 col-md-5');

                $('#text_metadata_container').toggleClass('col-md-1 col-md-2');
                $('#text_metadata_container').toggleClass('nometa');
                $('#text_ocr_container').toggleClass('col-md-6 col-md-5');
            });

            // set up handler for ocr fullscreen
            $('#ocrFullscreenButton').click(function(e) {
                // Copy/Pasted from http://stackoverflow.com/questions/7130397/how-do-i-make-a-div-full-screen /HAFE
                // if already full screen; exit
                // else go fullscreen
                if (
                    document.fullscreenElement ||
                    document.webkitFullscreenElement ||
                    document.mozFullScreenElement ||
                    document.msFullscreenElement
                ) {
                    if (document.exitFullscreen) {
                        document.exitFullscreen();
                    } else if (document.mozCancelFullScreen) {
                        document.mozCancelFullScreen();
                    } else if (document.webkitExitFullscreen) {
                        document.webkitExitFullscreen();
                    } else if (document.msExitFullscreen) {
                        document.msExitFullscreen();
                    }
                } else {
                    var element = $('.ocr').get(0);
                    if (element.requestFullscreen) {
                        element.requestFullscreen();
                    } else if (element.mozRequestFullScreen) {
                        element.mozRequestFullScreen();
                    } else if (element.webkitRequestFullscreen) {
                        element.webkitRequestFullscreen(Element.ALLOW_KEYBOARD_INPUT);
                    } else if (element.msRequestFullscreen) {
                        element.msRequestFullscreen();
                    }
                }
            });

            $('.escFullScreenButton').click(dkBreve.closeFullScreen);
        },
        onKbOSDReady : function (kbosd) {
            var that = this;
            that.kbosd = kbosd;
            if (kbosd.pageCount > 1) { // if there isn't more than one page, no synchronization between the panes are needed.
                that.gotoOcrPage(kbosd.getCurrentPage(), true);
                $(kbosd.contentElem).on('pagechange', function (e) {
                    if (!that.scrollingInProgress && !that.fullScreen) {
                        that.gotoOcrPage(e.detail.page);
                    }
                });
                $(kbosd.contentElem).on('fullScreen', that.onFullScreen);

                $('.ocr').scroll(this.onOcrScroll);
            }
        },
        closeFullScreen : function () {
            if (document.exitFullscreen) {
                document.exitFullscreen();
            } else if (document.mozCancelFullScreen) {
                document.mozCancelFullScreen();
            } else if (document.webkitExitFullscreen) {
                document.webkitExitFullscreen();
            } else if (document.msExitFullscreen) {
                document.msExitFullscreen();
            }
        }
    };

    return new DkBreve();
})(window,jQuery);

$(document).on('kbosdready', function(e) {
    dkBreve.onKbOSDReady(e.detail.kbosd);
});
