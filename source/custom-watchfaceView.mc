import Toybox.Application;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Timer as Timer;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Graphics as Gfx;
using Toybox.Lang as Language;
using Toybox.Math as Math;
using Toybox.System as Sys;

class custom_watchfaceView extends WatchUi.WatchFace {

    var cascadiaFont;
    var firaCodeFont;
    var backgroundImage;
    var updateTimer;

    var backgroundColor = Gfx.createColor(255, 0, 0, 0); // alpha, red, green, blue
    var shadowColor = Gfx.createColor(50, 0, 0, 0); // alpha, red, green, blue

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Gfx.Dc) as Void {
        cascadiaFont = WatchUi.loadResource(Rez.Fonts.CascadiaFont);
        firaCodeFont = WatchUi.loadResource(Rez.Fonts.FiraCodeFont);

        backgroundImage = WatchUi.loadResource(Rez.Drawables.BackgroundImage);
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        // dc.drawBitmap(0, 0, backgroundImage);
        dc.setColor(backgroundColor, backgroundColor);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        var clockRadius = (width / 2) - 10;

        // drawHourNumbers(dc, centerX, centerY, clockRadius);
        drawHourTicks(dc, centerX, centerY, clockRadius);
        // drawMinuteTicks(dc, centerX, centerY, clockRadius);
        drawDate(dc, centerX, centerY, clockRadius);
        drawBattery(dc, centerX, centerY, clockRadius);
        drawHands(dc, centerX, centerY, clockRadius);
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        updateTimer = new Timer.Timer();
        updateTimer.start(method(:onTimerTick), 1000, true);
    }

    function onEnterSleep() as Void {
        if (updateTimer != null) {
            updateTimer.stop();
            updateTimer = null;
        }
    }

    function onTimerTick() as Void {
        WatchUi.requestUpdate();
    }

    // Custom methods
    function drawDate(dc, centerX, centerY, radius) {
        var now = Time.now();
        var date = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var dateString = Language.format("$1$, $2$ $3$", [date.day_of_week, date.month, date.day]);
        dateString = dateString.toUpper();

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        var dateY = centerY + (radius * 0.5);
        dc.drawText(centerX, dateY, Gfx.FONT_XTINY, dateString, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    // function drawHourNumbers(dc, centerX, centerY, radius) {
    //     dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    //     var numberRadius = radius - 30; // pull numbers slightly inward from the edge

    //     for (var i = 1; i <= 12; i++) {
    //         var angle = i * 30 * Math.PI / 180.0;
    //         var x = centerX + numberRadius * Math.sin(angle);
    //         var y = centerY - numberRadius * Math.cos(angle);
    //         dc.drawText(x, y, firaCodeFont, i.toString(), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    //     }
    // }

    function drawHourTicks(dc, centerX, centerY, radius) {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        for (var i = 0; i < 12; i++) {
            var angle = i * 30 * Math.PI / 180.0;
            var outerX = centerX + radius * Math.sin(angle);
            var outerY = centerY - radius * Math.cos(angle);
            var tickLength = 0;

            if (i % 3 == 0) {
                tickLength = 50;
                dc.setPenWidth(4);
            }
            else {
                tickLength = 20;
                dc.setPenWidth(3);
            }

            var innerRadius = radius - tickLength;
            var innerX = centerX + innerRadius * Math.sin(angle);
            var innerY = centerY - innerRadius * Math.cos(angle);
            dc.drawLine(innerX, innerY, outerX, outerY);
        }
    }

    // function drawMinuteTicks(dc, centerX, centerY, radius) {
    //     dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    //     dc.setPenWidth(1);

    //     for (var i = 0; i < 60; i++) {
    //         if ((i % 5 == 0)) {
    //             continue; // skip positions where hour numbers already sit
    //         }
    //         var angle = i * 6 * Math.PI / 180.0; // 360/60 = 6 degrees per minute
    //         var outerX = centerX + radius * Math.sin(angle);
    //         var outerY = centerY - radius * Math.cos(angle);
    //         var innerRadius = radius - 6; // short tick length
    //         var innerX = centerX + innerRadius * Math.sin(angle);
    //         var innerY = centerY - innerRadius * Math.cos(angle);
    //         dc.drawLine(innerX, innerY, outerX, outerY);
    //     }
    // }

    function drawHands(dc, centerX, centerY, radius) {
        var clockTime = Sys.getClockTime();
        var hour = clockTime.hour % 12;
        var minute = clockTime.min;
        var second = clockTime.sec;

        var minuteAngle = minute * 6 * Math.PI / 180.0;
        drawHand(dc, centerX, centerY, minuteAngle, radius * 0.9, 6, Gfx.COLOR_WHITE);

        var hourAngle = (hour * 30 + minute * 0.5) * Math.PI / 180.0;
        drawHand(dc, centerX, centerY, hourAngle, radius * 0.5, 7, Gfx.COLOR_WHITE);

        var secondHandAngle = second * 6 * Math.PI / 180.0;
        var secondHandLength = radius * 0.95;
        var secondHandThickness = 3;
        // drawHandShadowOffset(dc, centerX, centerY, secondHandAngle, secondHandLength * 0.95, secondHandThickness * 4, shadowColor, 2, 2);
        drawSecondsHand(dc, centerX, centerY, secondHandAngle, secondHandLength, secondHandThickness, Gfx.COLOR_RED);

        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 5);
    }

    function drawSecondsHand(dc, centerX, centerY, angle, length, penWidth, color) {
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(penWidth);
        var startX = centerX - (length - 150) * Math.sin(angle);
        var startY = centerY + (length - 150) * Math.cos(angle);
        var endX = centerX + length * Math.sin(angle);
        var endY = centerY - length * Math.cos(angle);

        dc.drawLine(startX, startY, endX, endY);
    }

    function drawHand(dc, centerX, centerY, angle, length, penWidth, color) {
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(penWidth);
        var endX = centerX + length * Math.sin(angle);
        var endY = centerY - length * Math.cos(angle);

        dc.drawLine(centerX, centerY, endX, endY);
    }

    function drawHandShadowOffset(dc, centerX, centerY, angle, length, penWidth, color, offsetX, offsetY) {
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(penWidth);
        var startX = centerX + offsetX;
        var startY = centerY + offsetY;
        var endX = centerX + length * Math.sin(angle) + offsetX;
        var endY = centerY - length * Math.cos(angle) + offsetY;
        dc.drawLine(startX, startY, endX, endY);
    }

    function drawBattery(dc, centerX, centerY, radius) {
        var stats = Sys.getSystemStats();
        var batteryPercent = stats.battery; // returns a Float, 0-100

        var iconWidth = 14;
        var iconHeight = 20;
        var nubWidth = 6;
        var nubHeight = 3;

        var iconX = centerX - (iconWidth / 2);
        var iconY = centerY - (radius * 0.55); // pushes icon toward top of face

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        // Battery body outline
        dc.drawRoundedRectangle(iconX, iconY, iconWidth, iconHeight, 2);

        // Battery nub (top, since icon is oriented vertically like your reference)
        var nubX = centerX - (nubWidth / 2);
        dc.fillRectangle(nubX, iconY - nubHeight, nubWidth, nubHeight);

        // Battery fill level (inset from the outline)
        var fillPadding = 3;
        var maxFillHeight = iconHeight - (fillPadding * 2);
        var fillHeight = (maxFillHeight * batteryPercent / 100.0).toNumber();
        var fillY = iconY + iconHeight - fillPadding - fillHeight;

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
        dc.fillRectangle(iconX + fillPadding, fillY, iconWidth - (fillPadding * 2), fillHeight);

        // Percentage text below icon
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        var percentText = batteryPercent.toNumber().toString() + "%";
        var textY = iconY + iconHeight + 25; // Text percentage Y position related to the Icon Y position
        dc.drawText(centerX, textY, Gfx.FONT_XTINY, percentText, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }
}