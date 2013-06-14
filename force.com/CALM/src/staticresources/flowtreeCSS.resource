.flow-tree-row {
    height: 3em;
    padding: 0 0 0.1em 0;
}

.flow-tree.vertical .flow-tree-row {
    float: left;
}

.flow-tree-node {
    display: inline-block;
    vertical-align: middle;
    text-align: center;
    //height: 1em;
    background-color: #EEE;
    border-color: #CCC;
    border-style: solid;
    border-width: 0.1em 0.2ex 0.1em 0.2ex;
    border-radius: 5px;
    margin: 0 1ex 0 1ex;
    padding: 1em 2ex 1em 2ex;
}

.flow-tree.vertical .flow-tree-node {
    display: block;
    margin: 0.5em 0 0.5em 0;
}

.flow-tree-node.selected {
    background-color: #D5E3FD;
}

.flow-tree-node-text {
	font-family: Arial, Verdana;
	font-size: 10pt;
	color: #444;
    //height: 1em;
}

.flow-tree-line-row {
    height: 4em;
}

.flow-tree-line {
    display: inline-block;
    position: absolute;
    height: 4em;
}

.flow-tree-line div {
    height: 50%;
    border-width: 0.1em;
    border-color: #CCC;
}

.flow-tree-line-top {
    border-bottom-style: solid;
    border-width: 1px;
    border-color: #CCC;
}

.flow-tree-line-text {
	font-size: small;
	padding-left: 1ex;
	padding-top: 0.45em;
    position: relative;
}

.flow-tree.vertical .flow-tree-line-row {
    float: left;
    width: 10ex;
    position: relative;
}

.flow-tree.vertical .flow-tree-line div {
    width: 50%;
    height: 100%;
    float: left;
}

.flow-tree-line-left {
    width: 50%;
    height: 100%;
    float: left;
}

.flow-tree-line-left div {
    border-right-style: solid;
    border-width: 1px;
    border-color: #CCC;
}

.flow-tree-line-right {
    width: 50%;
    float: right;
}

.flow-tree-line-right .flow-tree-line {
    width: 100%;
    border-color: #CCC;
    border-top-style: solid;
    border-width: 1px;
    display: block;
    position: initial;
}