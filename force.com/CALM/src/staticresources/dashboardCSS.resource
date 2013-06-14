html, body {
	margin:0;
	padding:0;
	border:0;
	width:100%;
	height:100%;
	background: #999999;
}

hidden {
    display:none;
}

a {
	color:#369;
}

h1, h2, h3 {
	margin:.8em 0 .2em 0;
	padding:0;
}

p {
	margin:.4em 0 .8em 0;
	padding:0;
}

img {
	margin:0px 0 0px;
	border: 0px;
}
	
#page_container {
	background:#fff;
	margin-left: auto;
	margin-right: auto;
	width: 80%;
	min-width: 950px;
	min-height: 100%;
}
	
/* Header styles */
#header {
	clear:both;
	float:left;
	width:100%
}

#header {
	border-bottom:1px solid #000;
	background-color:#2e3436; 
}

#header p,
#header h1,
#header h2 {
	padding:.4em 15px 0 15px;
	margin:0;
}

.right {
	float: right;
}

/* column container */
.colmask {
	position:relative;	/* This fixes the IE7 overflow hidden bug */
	clear:both;
	float:left;
	width:100%;			/* width of whole page */
	overflow:hidden;	/* This chops off any overhanging divs */
}

.col1 {
	float:left;
	position:relative;
	padding:0 0 1em 0;
	overflow:hidden;
}

/* Full page settings */
.fullpage {
	background:#fff;		/* page background colour */
}

.fullpage .col1 {
	width:96%;			/* page width minus left and right padding */
	left:2%;			/* page left padding */
}
	
#chart {
	min-height: 600px;
	height: 100%;
}
	
select{
    height:25px;
}

.align-left{
    float:left;
}
.align-right{
    float:right;
}

ul {
   font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
   font-size: 16px;
   list-style: none;
   margin: 0;
   padding: 0;
}

ul li {
   display: block;
   float: left;
   position: relative;
}
                
li ul { display: none; }

li .align-left{
    padding-left:10px;
}
li .align-right{
    padding-right:10px;
}

li.oracle-li{
    display:none;
}

div.oracle-steps-container{
    display:none;
}

.disabled-message a {
	text-decoration:none;
	font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
}

a.remove-step, a.view-mode, a.create-mode, a.new-funnel{
    color:#333;
    font-size:10pt;
    vertical-align:middle;
}

a.disabled{
    color: #ccc;
}
a.disabled:hover{
    cursor:default;
}


#modal-input-funnel, #modal-input-screen {
	width:30px;
}

span.prev-depth{
	padding-left:15px;
}

span{
    font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size:10pt;
}

span.note{
	font-size:9pt;
}

span.funnel-screen-depth{
	padding-right:9px;
}

span.app-id{
	font-family: monospace;
}

span.input-error, span.step-error{
    color:#dc143c;
    display:none;
    padding-left:5px;
    font-weight:bold;
}

span.save-error {
    color:#dc143c;
    font-weight:bold;
}

span.step-count {
    color:#a3a3a3;
}

span.step-count {
    color:#a3a3a3;
}

.loading, .no-apps-message, .disabled-message, .no-screens-message, .no-funnels-message {
    font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size:30pt;
    color:#a3a3a3;
    text-align:center;
    padding-top:55px;
    display:none;
}

.funnel-menu-bar, .steps_container {
    overflow: hidden;
    display: inline-block; /* Necessary to trigger "hasLayout" in IE */
    display: block; /* Sets element back to block */
}

.funnel-menu-bar {
    display:none;
    width:95%;
    padding-top:25px;
    margin-left:auto;
    margin-right:auto;
}

.funnel-header{
    background-color: #eee;
    -moz-border-radius-topleft: 5px;
    -webkit-border-top-left-radius: 5px;
    border-top-left-radius: 5px;
    -moz-border-radius-topright: 5px;
    -webkit-border-top-right-radius: 5px;
    border-top-right-radius: 5px;
}

.funnel-header div a.close-icon img{
    margin-left:15px;
    vertical-align:middle;
    background-color:#a3a3a3;
}

.funnel-header div a.close-icon img:hover{
    background-color:#dc143c;
}

.funnel-header input{
    padding: 4px;
    margin-left: 10px;
    margin-top: 4px;
    width: 250px;
}

.funnel-header input:disabled{
    background-color: #eee;
    border: 0px;
    font-weight:bold;
}

.step-name{
    width:100%;
    padding-bottom:5px;
}

.step-bar{
    clear:both;
    background:-webkit-gradient(linear, left top, left bottom, color-stop(0%, #eeeeee), color-stop(99%, #f3f3f3));
    height:25px;
    width:98%;
    margin:auto;
    border-radius: 20px;
    box-shadow: inset 0 1px 1px #e5e5e5;
}

.step-bar-fill{
    background: #26a2d3;
    background: -webkit-gradient(linear, left top, left bottom, color-stop(0%, #3ab0da), color-stop(99%, #1c8fc7));
    background: -moz-linear-gradient(top, #3ab0da 0%, #1c8fc7 100%);
    background: linear-gradient(top, #3ab0da 0%, #1c8fc7 100%);
    height:25px;
    box-shadow: inset 0 1px 1px #63c0e2;
    border: solid 1px #197fb0;
    border-radius: 150px;
    -webkit-border-radius: 150px;
    -moz-border-radius: 150px;
}

.create-mode, .view-mode{
    display:none;
}

.steps_container{
    margin-top:25px;
    margin-left:auto;
    margin-right:auto;
    padding:3px;
    width:95%;
}

.step_list{
    margin-left:auto;
    margin-right:auto;
    width:100%;
}

.step_list li{
   margin:auto;
   padding-top:10px;
   padding-bottom:10px;
   width: 100%;
   border-bottom: 1px solid #ccc;
   border-right: 1px solid #ccc;
   border-left: 1px solid #ccc;
}

.step_list li:first-child{
   border-top: 1px solid #ccc;
}

li.alternate{
   background-color:#edf3fe;
}

.buttons-container *{
    margin-top:5px;
    padding-top:5px;
    padding-bottom:5px;
}

.hidden{
   display:none;
}

.shown{
   display:block;
}

label{
   color: #444;
   font-family: times, Times New Roman, times-roman, georgia, serif;
   font-size: 14px;
   line-height: 20px;
}

label.control-label{
	color: #333;
	font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
	font-size: 14px;
	font-weight: normal;
	line-height: 20px;
}

img {
   border : 0;
}

#logo {
   float: left;
   margin-left: 5px;
}

#top_ban {
   float: left;
   margin: 5px;
   margin-left: 20px;
}

.chart_container{
   background-color:#fff;
   margin: 0px 0px;
   width: 100%;
   height: 100%;
}

.web_chart_container{
   background-color:#fff;
   margin: 0px 0px;
   width: 100%;
   min-height: 700px;
}

#datePicker {
   background-color:#ffffff;
   margin-left: auto;
   margin-right: auto;
   margin-top: 5px;
   padding: 5px;
   clear: both;
}

#messages {
   background-color:#ffffff;
   margin-bottom: 5px;
   margin-left: auto;
   margin-right: auto;
   margin-top: 5px;
   text-align: center;
   clear: both;
}

#multigraph {
}

#menu {

}

#chart {	
   clear: both;
}


/* Font styles */
.basic{
   color: #444;
   font-family: times, Times New Roman, times-roman, georgia, serif;
   font-size: 14px;
   line-height: 20px;
}

.heading{
   color: #444;
   font-family: times, Times New Roman, times-roman, georgia, serif;
   font-size: 48px;
   font-weight: 100;
   line-height: 40px;
   letter-spacing: -1px;
   margin: 0px 0px 0px 0px;
   padding: 0px 0px 0px 0px;
}

.basic_alt {
	color: #444;
	font-family: ˜Trebuchet MS, Helvetica, sans-serif;
}




/* Main Navigation */
#nav{
	margin: 0;
	padding: 10px 0 0 0;
	list-style: none; 
}

#nav li{
	float: left;
	padding: 0 0 10px 0;
	position: relative;
}

#nav a{
	float: left;
	height: 25px;
	padding: 0 25px;
	color: #999;
	text-transform: uppercase;
	font: bold 12px/25px Arial, Helvetica;
	text-decoration: none;
	text-shadow: 0 1px 0 #000;
}

#nav li:hover > a{
	color: #fafafa;
}

*html #nav li a:hover{ /* IE6 */
	color: #fafafa;
}

#nav li:hover > ul{
	display: block;
}

/* Sub-menu */

#nav ul{
    list-style: none;
    margin: 0;
    padding: 0;    
    display: none;
    position: absolute;
    top: 35px;
    left: 0;
    z-index: 99999;    
    background: #444;
    background: -moz-linear-gradient(#444, #111);
    background: -webkit-gradient(linear,left bottom,left top,color-stop(0, #111),color-stop(1, #444));
    background: -webkit-linear-gradient(#444, #111);    
    background: -o-linear-gradient(#444, #111);	
    background: -ms-linear-gradient(#444, #111);	
    background: linear-gradient(#444, #111);	
    -moz-border-radius: 5px;
    border-radius: 5px;
}

#nav ul li{
    float: none;
    margin: 0;
    padding: 0;
    display: block;  
    -moz-box-shadow: 0 1px 0 #111111, 0 2px 0 #777777;
    -webkit-box-shadow: 0 1px 0 #111111, 0 2px 0 #777777;
    box-shadow: 0 1px 0 #111111, 0 2px 0 #777777;
}

#nav ul li:last-child{   
    -moz-box-shadow: none;
    -webkit-box-shadow: none;
    box-shadow: none;    
}

#nav ul a{    
    padding: 10px;
    height: auto;
    line-height: 1;
    display: block;
    white-space: nowrap;
    float: none;
    text-transform: none;
}

*html #nav ul a{ /* IE6 */   
	height: 10px;
	width: 150px;
}

*:first-child+html #nav ul a{ /* IE7 */    
	height: 10px;
	width: 150px;
}

#nav ul a:hover{
    background: #336699;
	background: -moz-linear-gradient(#04acec,  #336699);	
	background: -webkit-gradient(linear, left top, left bottom, from(#04acec), to(#336699));
	background: -webkit-linear-gradient(#04acec,  #336699);
	background: -o-linear-gradient(#04acec,  #336699);
	background: -ms-linear-gradient(#04acec,  #336699);
	background: linear-gradient(#04acec,  #336699);
}

#nav ul li:first-child a{
    -moz-border-radius: 5px 5px 0 0;
    -webkit-border-radius: 5px 5px 0 0;
    border-radius: 5px 5px 0 0;
}

#nav ul li:first-child a:after{
    content: '';
    position: absolute;
    left: 30px;
    top: -8px;
    width: 0;
    height: 0;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    border-bottom: 8px solid #444;
}

#nav ul li:first-child a:hover:after{
    border-bottom-color: #04acec; 
}

#nav ul li:last-child a{
    -moz-border-radius: 0 0 5px 5px;
    -webkit-border-radius: 0 0 5px 5px;
    border-radius: 0 0 5px 5px;
}

/* Clear floated elements */
#nav:after{
	visibility: hidden;
	display: block;
	font-size: 0;
	content: " ";
	clear: both;
	height: 0;
}

* html #nav             { zoom: 1; } /* IE6 */
*:first-child+html #nav { zoom: 1; } /* IE7 */