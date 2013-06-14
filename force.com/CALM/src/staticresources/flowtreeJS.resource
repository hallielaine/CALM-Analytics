/*!
 * Flow Tree JavaScript Library
 * Copyright 2013 Erik Sandberg
 */

/**
 * A FlowTreeNode is a node in the FlowTree. It is part of a FlowTreeRow that may contain other FlowTreeNodes.
 * If it is selected, it may have one or more children. It may contain text. The line connecting it to it's parent node may have a label.
 * @param row The FlowTreeRow that this is a part of.
 * @param params A hash that may contain any of the following fields:
 * text: The text that the node contains.
 * lineText: The text on the line connecting the parent to the node.
 * selected: Boolean indicating if this node is selected.
 * makeClickHandler: Function that takes this node as it's only parameter and returns a click handler.
 */
var FlowTreeNode = function (row, params) {
    /** The FlowTreeRow that contains this FlowTreeNode. */
    this.row = row;
    /** The FlowTreeNode that is selected in the previous FlowTreeRow. May be null if first row. */
    this.parent = row.parent;
    /** The params hash that was passed in to the constructor. */
    this.params = params;
    /** The text that this node should display. */
    this.text = params.hasOwnProperty('text') ? params.text : '';
    /** The text that should display next to the line coming from the parent. */
    this.lineText = params.hasOwnProperty('lineText') ? params.lineText : '';
    /** Boolean indicating whether or not this node is selected. */
    this.selected = (params.hasOwnProperty('selected') && (params.selected == "true" || params.selected == true)) ? true : false;
    /** The jQuery object representing the view for this FlowTreeNode. */
    this.$ = FlowTreeNode.makeView(this);
    if (params.hasOwnProperty('makeClickHandler') && typeof (params.makeClickHandler) == 'function') {
        this.$.on('click',params.makeClickHandler(this));
    }
};

/**
 * Makes the view for the FlowTreeNode.
 * @param node The node to make the view for.
 * @return A jQuery object that represents the view for the given node.
 */
FlowTreeNode.makeView = function (node) {
    var box = $('<div>').addClass('flow-tree-node');
    
    if (node.selected) {
        box.addClass('selected');
    }
    
    var text = node.text;
    if (!node.parent && node.lineText) {
        text = "(" + node.lineText + ") " + node.text;
    }
    box.append($('<div>').addClass('flow-tree-node-text').html(text));
    
    return box;
};

FlowTreeNode.prototype.width = function () {
    return this.$.outerWidth(true);
};

/**
 * @param from The FlowTreeNode to draw the line from.
 * @param to The FlowTreeNode to draw the line to.
 */
var FlowTreeLine = function (from, to) {
    this.from = from;
    this.to = to;
    this.updateView();
};

/**
 * @param from The FlowTreeNode to draw the line from.
 * @param to The FlowTreeNode to draw the line to.
 * @return The jquery object that represents view of the line.
 */
FlowTreeLine.makeView = function (from, to) {
    var tree = from.row.tree;
    var vertical = tree.vertical;
    if (vertical) {
        return FlowTreeLine.makeVerticalView(from, to);
    }
    else {
        return FlowTreeLine.makeHorizontalView(from, to);
    }
};

FlowTreeLine.makeVerticalView = function (from, to) {
    var fromCenter = from.$.position().top + from.$.outerHeight()/2;
    var fromRight = from.$.position().left + from.$.outerWidth();
    var toCenter = to.$.position().top + to.$.outerHeight()/2;
    var toLeft = from.$.position().left;

    var container = $('<div>').addClass('flow-tree-line');
    var lineLeft = $('<div>').addClass('flow-tree-line-left');
    var lineRight = $('<div>').addClass('flow-tree-line-right');
    var lineText = null;
    if (to.hasOwnProperty('lineText')) {
        lineText = $('<div>').addClass('flow-tree-line-text').text(to.lineText);
	    lineRight.append(lineText);
    }
    container.append(lineLeft).append(lineRight);
    
    container.height(Math.abs(fromCenter-toCenter)+1);
    container.css('left', fromRight);
    container.css('top', Math.min(fromCenter,toCenter));
    
    if (fromCenter < toCenter) {
        lineTop.css('border-top-style', 'solid');
        lineBottom.css('border-bottom-style', 'solid');
    }
    else {
        lineTop.css('border-bottom-style', 'solid');
        lineBottom.css('border-top-style', 'solid');
    }
    
    return container;
};

FlowTreeLine.makeHorizontalView = function (from, to) {
    var fromCenter = from.$.position().left + from.$.outerWidth()/2;
    var fromBottom = from.$.position().top + from.$.outerHeight();
    var toCenter = to.$.position().left + to.$.outerWidth()/2;
    var toTop = from.$.position().top;

    var container = $('<div>').addClass('flow-tree-line');
    var lineTop = $('<div>').addClass('flow-tree-line-top');
    var lineBottom = $('<div>').addClass('flow-tree-line-bottom');
    var lineText = null;
    if (to.hasOwnProperty('lineText')) {
        lineText = $('<div>').addClass('flow-tree-line-text').text(to.lineText);
	    lineBottom.append(lineText);
    }
    container.append(lineTop).append(lineBottom);

    container.width(Math.abs(fromCenter-toCenter)+1);
    container.css('top',fromBottom);
    container.css('left',Math.min(fromCenter,toCenter));
    
    if (fromCenter < toCenter) {
        lineTop.css('border-left-style', 'solid');
        lineBottom.css('border-right-style', 'solid');
        if (lineText) {
            lineText.css('left',container.position().left + container.width());
        }
    }
    else {
        lineTop.css('border-right-style', 'solid');
        lineBottom.css('border-left-style', 'solid');
    }

    return container;
};

FlowTreeLine.prototype.updateView = function () {
    if (this.hasOwnProperty('$')) {
        this.$.remove();
    }
    this.$ = FlowTreeLine.makeView(this.from, this.to);
    var lineRow;
    if (this.from.row.$.next().hasClass('flow-tree-line-row')) {
        lineRow = this.from.row.$.next();
    }
    else {
        lineRow = $('<div>').addClass('flow-tree-line-row');
        this.from.row.$.after(lineRow);
    }
    lineRow.append(this.$);
};

var FlowTreeLineRow = function (fromRow, toRow) {
    this.fromRow = fromRow;
    this.toRow = toRow;
    this.$ = FlowTreeLineRow.makeView (fromRow, toRow);
};

FlowTreeLineRow.prototype.updateView = function () {
    if (this.hasOwnProperty('$')) {
        this.$.remove();
    }
    this.$ = FlowTreeLineRow.makeView(this.fromRow, this.toRow);
};

FlowTreeLineRow.makeView = function (fromRow, toRow) {
    if (fromRow.tree.vertical) {
        return FlowTreeLineRow.makeVerticalView (fromRow, toRow);
    }
    else {
        return FlowTreeLineRow.makeHorizontalView (fromRow, toRow);
    }
};

FlowTreeLineRow.makeVerticalView = function (fromRow, toRow) {
    var container = $('<div>').addClass('flow-tree-line-row');
    fromRow.$.after(container);
    
    if (fromRow['selected']) {
        var from = {};
        from.node = fromRow.selected;
        from.center = from.node.$.position().top + from.node.$.outerHeight()/2;
        
        var to = {
            'top':{},
            'bottom':{}
        };
        to.top.node = toRow.nodes[0];
        to.top.center = to.top.node.$.position().top + to.top.node.$.outerHeight()/2;
        to.bottom.node = toRow.nodes[toRow.nodes.length-1];
        to.bottom.center = to.bottom.node.$.position().top + to.bottom.node.$.outerHeight()/2;
        
        container.css('top', Math.min(from.center, to.top.center));
        container.height(Math.max(Math.max(to.bottom.center,from.center) - Math.min(from.center,to.top.center),1));
        
        var leftLine = $('<div>').addClass('flow-tree-line-left');
        container.append(leftLine);
        var leftTopLine = $('<div>').addClass('flow-tree-line-top');
        var leftBottomLine = $('<div>').addClass('flow-tree-line-bottom');
        leftTopLine.height(Math.max(from.center - to.top.center,0));
        leftBottomLine.height(Math.max(to.bottom.center - from.center,0));
        
        leftLine.append(leftTopLine).append(leftBottomLine);
        
        var rightLine = $('<div>').addClass('flow-tree-line-right');
        container.append(rightLine);
        
        for (var i = 1; i < toRow.nodes.length; i++) {
            var line = $('<div>').addClass('flow-tree-line');
            rightLine.append(line);
            var topNode = toRow.nodes[i-1];
            var bottomNode = toRow.nodes[i];
            if (topNode.hasOwnProperty('lineText')) {
                var lineText = $('<div>').addClass('flow-tree-line-text').text(topNode.lineText);
                line.append(lineText);
            }
            line.height(topNode.$.outerHeight()/2 + bottomNode.$.outerHeight()/2 + Math.max(parseInt(topNode.$.css('marginBottom')),parseInt(bottomNode.$.css('marginTop'))) - parseInt(line.css('border-top-width')));
        }
        var line = $('<div>').addClass('flow-tree-line');
        rightLine.append(line);
        if (to.bottom.node.hasOwnProperty('lineText')) {
            var lineText = $('<div>').addClass('flow-tree-line-text').text(to.bottom.node.lineText);
            line.append(lineText);
        }
    }
    
    return container;
};

FlowTreeLineRow.makeHorizontalView = function (fromRow, toRow) {
    var i, line, container;
    
    container = $('<div>').addClass('flow-tree-line-row');
    fromRow.$.after(container);
    
    for (i = 0; i < toRow.nodes.length; i++) {
        line = new FlowTreeLine (fromRow.selected, toRow.nodes[i]);
        container.append (line.$);
    }
    
    return container;
};

var FlowTreeRow = function (tree, nodeParams, parent) {
    this.parent = parent || null;
    this.tree = tree;
    this.nodes = [];

    var i;
    for (i = 0; i < nodeParams.length; i++) {
        this.nodes[i] = new FlowTreeNode(this,nodeParams[i]);
        if (this.nodes[i].hasOwnProperty('selected')) {
            if (nodeParams[i].selected == 'true' || nodeParams[i].selected == true) {
                this.selected = this.nodes[i];
            }
        }
    }

    this.$ = FlowTreeRow.makeView(this.nodes);
    
    if (this.parent) {
        this.lineRow = new FlowTreeLineRow (this.parent.row, this);
    }
};

FlowTreeRow.makeView = function (nodes) {
    var row = $('<div>');
    row.addClass('flow-tree-row');
    var i;
    for (i in nodes) {
      row.append(nodes[i].$);
    }
    return row;
};

FlowTreeRow.prototype.updateView = function () {
    if (this.hasOwnProperty('lineRow')) {
        this.lineRow.updateView();
    }
};

FlowTreeRow.prototype.getIndex = function () {
    return this.tree.rows.indexOf(this);
};

FlowTreeRow.prototype.remove = function () {
    if (this.$.prev().hasClass('flow-tree-line-row')) {
        this.$.prev().remove();
    }
    this.$.remove();
};

FlowTreeRow.prototype.setSelected = function (node) {
    var i;
    for (i = 0; i < this.nodes.length; i++) {
        if (this.nodes[i] === node) {
            this.nodes[i].selected = true;
            this.nodes[i].$.addClass('selected');
        }
        else {
            this.nodes[i].selected = false;
            this.nodes[i].$.removeClass('selected');
        }
    }
    this.selected = node;
};

FlowTreeRow.prototype.width = function () {
    var i, width = 0;
    for (i = 0; i < this.nodes.length; i++) {
        width += this.nodes[i].width();
    }
    return width;
};

var FlowTree = function (params) {
    this.rows = [];
    this.vertical = (params && params['vertical']);
    this.$ = FlowTree.makeView(params);
    
    if (params['appendTo']) {
        params.appendTo.append(this.$);
    }
    
    if (params.hasOwnProperty('rows')) {
        var i;
        for (i = 0; i < params.rows.length; i++) {
            this.addRow(params.rows[i], false);
        }
    }
        
    this.updateView ();
};

FlowTree.makeView = function(params) {
    var verticalClass = '';
    if (params && params['vertical']) {
        verticalClass = 'vertical';
    }
    return $('<div>').addClass ('flow-tree ' + verticalClass);
};

FlowTree.prototype.updateView = function () {
    var i, width;
    
    this.$.width(this.width());
	for (i = 0; i < this.rows.length; i++) {
        this.rows[i].updateView ();
    }
    this.$.width(this.width());
};

FlowTree.prototype.addRow = function (rowParams,update) {
    if (update === undefined) {
        update = true;
    }
    var lastNdx = this.rows.length - 1;
    var selected = (lastNdx >= 0 ? this.rows[lastNdx].selected : null);
    this.rows[lastNdx+1] = new FlowTreeRow (this, rowParams, selected);
    this.$.append (this.rows[lastNdx+1].$);
    if (update) {
        this.updateView();
    }
};

FlowTree.prototype.removeRow = function () {
    var last = this.rows.pop();
    last.remove();
};

FlowTree.prototype.width = function () {
    var i, curWidth, width = 0;
    
    if (this.vertical) {
        width = this.rows.length * this.rows[0].$.outerWidth();
        if (this.rows.length > 1) {
            width += (this.rows.length-1) * this.rows[1].lineRow.$.outerWidth();
        }
    }
    else {
        for (i = 0; i < this.rows.length; i++) {
            curWidth = this.rows[i].width();
            if (curWidth > width) {
                width = curWidth;
            }
        }
    }
    return width;
};