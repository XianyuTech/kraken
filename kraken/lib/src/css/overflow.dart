import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/rendering.dart';
import 'package:kraken/css.dart';

// CSS Overflow: https://drafts.csswg.org/css-overflow-3/

enum CSSOverflowType {
  auto,
  visible,
  hidden,
  scroll,
}

List<CSSOverflowType> getOverflowTypes(CSSStyleDeclaration style) {
  CSSOverflowType overflowX  = _getOverflowType(style[OVERFLOW_X]);
  CSSOverflowType overflowY  = _getOverflowType(style[OVERFLOW_Y]);

  // Apply overflow special rules from w3c.
  if (overflowX == CSSOverflowType.visible && overflowY != CSSOverflowType.visible) {
    overflowX = CSSOverflowType.auto;
  }

  if (overflowY == CSSOverflowType.visible && overflowX != CSSOverflowType.visible) {
    overflowY = CSSOverflowType.auto;
  }

  return [overflowX, overflowY];
}

CSSOverflowType _getOverflowType(String definition) {
  switch (definition) {
    case 'hidden':
      return CSSOverflowType.hidden;
    case 'scroll':
      return CSSOverflowType.scroll;
    case 'auto':
      return CSSOverflowType.auto;
    case 'visible':
    default:
      return CSSOverflowType.visible;
  }
}

mixin CSSOverflowMixin {
  RenderBox renderScrollViewPortX;
  RenderBox renderScrollViewPortY;
  KrakenScrollable _scrollableX;
  KrakenScrollable _scrollableY;

  RenderObject initOverflowBox(RenderObject current, CSSStyleDeclaration style,
      void scrollListener(double scrollTop, AxisDirection axisDirection)) {
    assert(style != null);
    List<CSSOverflowType> overflow = getOverflowTypes(style);
    // X direction overflow
    renderScrollViewPortX = _getRenderObjectByOverflow(overflow[0], current, AxisDirection.right, scrollListener);
    // Y direction overflow
    renderScrollViewPortY =
        _getRenderObjectByOverflow(overflow[1], renderScrollViewPortX, AxisDirection.down, scrollListener);
    return renderScrollViewPortY;
  }

  void updateOverFlowBox(
      CSSStyleDeclaration style, void scrollListener(double scrollTop, AxisDirection axisDirection)) {
    if (style != null) {
      List<CSSOverflowType> overflow = getOverflowTypes(style);

      if (renderScrollViewPortY != null) {
        RenderObject parent = renderScrollViewPortY.parent;
        AxisDirection axisDirection = AxisDirection.down;
        setChild(renderScrollViewPortY, null);
        switch (overflow[1]) {
          case CSSOverflowType.visible:
            setChild(parent, null);
            CSSOverflowDirectionBox overflowCustomBox = CSSOverflowDirectionBox(
                child: renderScrollViewPortX, textDirection: TextDirection.ltr, axisDirection: axisDirection);
            setChild(parent, renderScrollViewPortY = overflowCustomBox);
            _scrollableY = null;
            break;
          case CSSOverflowType.auto:
          case CSSOverflowType.scroll:
            setChild(parent, null);
            setChild(renderScrollViewPortX.parent, null);
            _scrollableY = KrakenScrollable(axisDirection: axisDirection, scrollListener: scrollListener);
            setChild(parent, renderScrollViewPortY = _scrollableY.getScrollableRenderObject(renderScrollViewPortX));
            break;
          case CSSOverflowType.hidden:
            setChild(parent, null);
            setChild(
                parent,
                renderScrollViewPortY = RenderSingleChildViewport(
                    axisDirection: axisDirection,
                    offset: ViewportOffset.zero(),
                    child: renderScrollViewPortX,
                    shouldClip: true));
            _scrollableY = null;
            break;
        }
      }

      if (renderScrollViewPortX != null) {
        RenderObject parent = renderScrollViewPortX.parent;
        RenderObject child = (renderScrollViewPortX as RenderObjectWithChildMixin<RenderBox>).child;
        AxisDirection axisDirection = AxisDirection.right;
        setChild(parent, null);
        setChild(renderScrollViewPortX, null);
        switch (overflow[0]) {
          case CSSOverflowType.visible:
            setChild(
                parent,
                renderScrollViewPortX = CSSOverflowDirectionBox(
                    child: child, textDirection: TextDirection.ltr, axisDirection: axisDirection));
            _scrollableX = null;
            break;
          case CSSOverflowType.auto:
          case CSSOverflowType.scroll:
            _scrollableX = KrakenScrollable(axisDirection: axisDirection, scrollListener: scrollListener);
            setChild(parent, renderScrollViewPortX = _scrollableX.getScrollableRenderObject(child));
            break;
          case CSSOverflowType.hidden:
            setChild(
                parent,
                renderScrollViewPortX = RenderSingleChildViewport(
                    axisDirection: axisDirection, offset: ViewportOffset.zero(), child: child, shouldClip: true));
            _scrollableX = null;
            break;
        }
      }
    }
  }

  RenderObject _getRenderObjectByOverflow(CSSOverflowType overflow, RenderObject current, AxisDirection axisDirection,
      void scrollListener(double scrollTop, AxisDirection axisDirection)) {
    switch (overflow) {
      case CSSOverflowType.visible:
        if (axisDirection == AxisDirection.right) {
          _scrollableX = null;
        } else {
          _scrollableY = null;
        }
        current = CSSOverflowDirectionBox(
          child: current,
          textDirection: TextDirection.ltr,
          axisDirection: axisDirection,
        );
        break;
      case CSSOverflowType.auto:
      case CSSOverflowType.scroll:
        KrakenScrollable scrollable = KrakenScrollable(axisDirection: axisDirection, scrollListener: scrollListener);
        if (axisDirection == AxisDirection.right) {
          _scrollableX = scrollable;
        } else {
          _scrollableY = scrollable;
        }
        current = scrollable.getScrollableRenderObject(current);
        break;
      case CSSOverflowType.hidden:
        if (axisDirection == AxisDirection.right) {
          _scrollableX = null;
        } else {
          _scrollableY = null;
        }
        current = RenderSingleChildViewport(
            axisDirection: axisDirection, offset: ViewportOffset.zero(), child: current, shouldClip: true);
        break;
    }
    return current;
  }

  double getScrollTop() {
    if (_scrollableY != null) {
      return _scrollableY.position?.pixels ?? 0;
    }
    return 0;
  }

  double getScrollLeft() {
    if (_scrollableX != null) {
      return _scrollableX.position?.pixels ?? 0;
    }
    return 0;
  }

  double getScrollHeight() {
    if (_scrollableY != null) {
      return _scrollableY.renderBox?.size?.height ?? 0;
    } else if (renderScrollViewPortY is RenderBox) {
      RenderBox renderObjectY = renderScrollViewPortY;
      return renderObjectY.hasSize ? renderObjectY.size.height : 0;
    }
    return 0;
  }

  double getScrollWidth() {
    if (_scrollableX != null) {
      return _scrollableX.renderBox?.size?.width ?? 0;
    } else if (renderScrollViewPortX is RenderBox) {
      RenderBox renderObjectX = renderScrollViewPortX;
      return renderObjectX.hasSize ? renderObjectX.size.width : 0;
    }
    return 0;
  }

  void scroll(List args, {bool isScrollBy = false}) {
    if (args != null && args.length > 0) {
      dynamic option = args[0];
      if (option is Map) {
        num top = option['top'];
        num left = option['left'];
        dynamic behavior = option['behavior'];
        Curve curve;
        if (behavior == 'smooth') {
          curve = Curves.linear;
        }
        _scroll(top, curve, isScrollBy: isScrollBy, isDirectionX: false);
        _scroll(left, curve, isScrollBy: isScrollBy, isDirectionX: true);
      }
    }
  }

  void _scroll(num aim, Curve curve, {bool isScrollBy = false, bool isDirectionX = false}) {
    Duration duration;
    KrakenScrollable scrollable;
    if (isDirectionX) {
      scrollable = _scrollableX;
    } else {
      scrollable = _scrollableY;
    }
    if (scrollable != null && aim != null) {
      if (curve != null) {
        double diff = aim - (scrollable.position?.pixels ?? 0);
        duration = Duration(milliseconds: diff.abs().toInt() * 5);
      }
      double distance;
      if (isScrollBy) {
        distance = (scrollable.position?.pixels ?? 0) + aim;
      } else {
        distance = aim.toDouble();
      }
      scrollable.position.moveTo(distance, duration: duration, curve: curve);
    }
  }
}

class CSSOverflowDirectionBox extends RenderSizedOverflowBox {
  AxisDirection axisDirection;

  CSSOverflowDirectionBox(
      {RenderObject child,
      Size requestedSize = Size.zero,
      AlignmentGeometry alignment = Alignment.topLeft,
      TextDirection textDirection,
      this.axisDirection})
      : assert(requestedSize != null),
        super(child: child, alignment: alignment, textDirection: textDirection, requestedSize: requestedSize);

  @override
  void performLayout() {
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = constraints.constrain(child.size);
      alignChild();
    } else {
      size = Size.zero;
    }
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      final Rect outerRect = offset & size;
      debugPaintPadding(context.canvas, outerRect, outerRect);
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AxisDirection>('axisDirection', axisDirection));
    properties.add(DiagnosticsProperty<TextDirection>('textDirection', textDirection, defaultValue: null));
  }

  @override
  bool hitTest(BoxHitTestResult result, { @required Offset position }) {
    if (hitTestChildren(result, position: position) || hitTestSelf(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }

    return false;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    return child?.hitTest(result, position: position);
  }
}

void setChild(RenderObject parent, RenderObject child) {
  if (parent is RenderObjectWithChildMixin)
    parent.child = child;
  else if (parent is ContainerRenderObjectMixin) parent.add(child);
}
