/* GLOBAL STYLES */
* {
	margin:0;
	padding:0;
}
html body {
	padding:0;
	margin:0;
	font-family: 'Open Sans', sans-serif  !important;
	color:#999;
	background:#f2f2f2;
	font-size:14px;
}
h1,h2,h3,h4,h5,h6 {
	font-family: 'Open Sans', sans-serif  !important;
	color:#353534  !important;
	font-weight:900 !important;
}
h1 {
	font-size:30px !important;
}
h2 {
	font-size:25px !important;
}
h3 {
	font-size:21px !important;
}
h4 {
	font-size:18px !important;
}
h5 {
	font-size:15px !important;
}
h6 {
	font-size:14px !important;
}
body a {
	font-weight:500;
	color:#3366cc;
	transition: color .25s ease-in-out;
   -moz-transition: color .25s ease-in-out;
   -webkit-transition: color .25s ease-in-out;
}
body a:hover, body a:active, body a:focus {
	text-decoration:none;
}
body label {
	display:block;
	margin-bottom:0;
}
body :focus {
    outline: none;
}
body input, body select, body textarea {
	box-shadow:none !important;
	-webkit-appearance: none !important;
}
textarea, input[type="text"] {
-webkit-appearance: none;
}


/* SOME GENERAL REUSABLE STYLES */
body .container {
	padding:0;
	color:#999;
}
.tableHeader {
	padding:8px 0;
	border-bottom:2px solid #e8e8e8;
}
.tableHeaderLeft {
	padding-top:4px;
}
.tableTitle {
	display:inline-block;
	margin-right:15px;
}
.tableAction {
	text-align:right;
}
.tableIcon {
	color:#353534;
}
.tableIcon:hover,
.tableIcon:active,
.tableIcon:focus {
	color:#f68c2c;
}
body .headerWrapper .container .slds-button,
.orangeButton {
	border-radius:0;
	border:none;
	color:#fff;
	background:#f68c2c;
	padding:5px 16px;
	line-height:20px;
	font-size:12px;
	border:2px solid transparent;
	cursor:pointer;
}
body .headerWrapper .container .slds-button:active,
.orangeButton:active, .orangeButtonLarge:active, .greyButton:active, .darkGreyButton:active,
body .headerWrapper .container .slds-button:focus,
.orangeButton:focus, .orangeButtonLarge:focus, .greyButton:focus, .darkGreyButton:focus {
	color:#fff;
}
body .smallButton {
	padding:2px 10px;
	font-size:80%;
}
.greyButton {
	border-radius:0;
	border:none;
	color:#fff;
	background:#999;
	padding:5px 16px;
	line-height:20px;
	font-size:12px;
	border:2px solid transparent;
	cursor:pointer;
}
.darkGreyButton {
	border-radius:0;
	border:none;
	color:#fff;
	background:#353534;
	padding:5px 16px;
	line-height:20px;
	font-size:12px;
	border:2px solid transparent;
	cursor:pointer;
}
.darkGreyButton:hover {
	background:#565656;
}
.darkGreyButtonLarge {
	font-size:15px;
	padding:11px 22px;
	border-radius:0;
	border:none;
	color:#fff;
	background:#353534;
	cursor:pointer;
	font-weight:400;
	letter-spacing:1px;
	text-transform:uppercase;
}
.darkGreyButtonLarge:hover {
	background:#565656;
}
.greyButton:hover {
	background:#868686;
}
.orangeButtonLarge {
	font-size:15px;
	padding:11px 22px;
	border-radius:0;
	border:none;
	color:#fff;
	background:#f68c2c;
	cursor:pointer;
	font-weight:400;
	letter-spacing:1px;
	text-transform:uppercase;
}
body .flexipagePage .container .slds-button:hover,
body .flexipagePage .container .slds-button:active,
body .flexipagePage .container .slds-button:focus,
.orangeButton:hover,
.orangeButton:active,
.orangeButton:focus,
.orangeButtonLarge:hover,
.orangeButtonLarge:active,
.orangeButtonLarge:focus {
	background:#e27b1d;
	color:#fff;
	text-decoration:none;
	box-shadow:inset 0 0 15px #707069;
}
.cardWrapper {
	background:#fff;
	margin:10px 0 12px 0;
}
.cardContent {
	padding:15px 20px;
}
.fieldData {
	color:#353534;
}
.pageTitle{
	margin:25px 0 15px;
}
/* STAR RATINGS */
.starRating span{
	color:#e8e8e8;
}
.starRating span.checked {
	color:#efce4a;
}
.starRating.Large {
	font-size:18px;
}
.strikeThrough {
	text-decoration:line-through;
	color:#999 !important;
}
.headerIcon {
	font-size:26px;
	margin-right:10px;
}
.cardTitle{
	margin-bottom:-5px;
}
.currentBreadcrumbItem {
	display:inline-block;
	background:#e8e8e8;
	padding:4px 12px;
	border-radius:3px;
	margin-left:5px;
}
.currentBreadcrumbItem.solo {
	margin-left:0;
}
.breadcrumbWrapper a {
	background:#f68c2c;
	padding:4px 12px;
	margin-right:5px;
	color:#fff;
	border-radius:3px;
}
.breadcrumbWrapper {
	margin-bottom:15px;
}





/* SALESFORCE OVERRIDES */
.flexipagePage {
	background:#f2f2f2;
}
header.flexipageHeader.slds-page-header.uiBlock.oneAnchorHeader {
	display:none;
}
.slds-template_default {
	padding:0;
}
.slds-brand-band.slds-brand-band_medium.slds-template_default.forceBrandBand {
	background:#f2f2f2;
	box-shadow:inset 0 0 12px rgba(0,0,0,0.15);
}
.list.slds-size--1-of-1.slds-show.slds-p-vertical--x-small.lookup__menu.invisible.uiAbstractList.uiAutocompleteList,
.list.slds-size--1-of-1.slds-show.slds-hidden.slds-p-vertical--x-small.lookup__menu.uiAbstractList.uiAutocompleteList {
	display:none;
}
.oneFlexipage .pageBody {
	overflow-x:hidden;
	margin:0;
}
.oneHeader.headerLayout {
	height:53px;
}


/* STANDARD SF PAGE(S) FIXES */
.forceBaseHome header {
	display:none !important;
}
.navContainer  {
	display:none !important;
}

.carousel-body .forceChatterRecordFeedContainerMobile .forceChatterFeed a,
.carousel-body .forceChatterRecordFeedContainerMobile .forceChatterFeed button {
	pointer-events:none !important;
}
.carousel-body .forceRecordLayout {
	padding:0 20px;
}
.carousel-body .forceRecordLayout a {
	pointer-events:none !important;
	color:#999 !important;
}
.carousel-body .forcePageBlockSection .section-header-title {
	margin:0;
}
.tablet .cuf-feed {
	opacity:0;
	height:1px !important;
	height: 1px !important;
	overflow:hidden !important;
	display:inline;
}
.tablet .cuf-feed .cuf-feedElementIterationItem {
	display:none !important;
}
.tablet .cuf-feed:before {
	content:'Chatter is currently disabled.';
	display:block;
	opacity:1;
    font-weight: 300;
    line-height: 1.25;
    font-size: 1.5rem;
    text-align:center;
    margin:35px 0 20px;
}
.tablet .cuf-feed:after {
	content: 'Please click the DETAILS tab, or return home.';
	display:block;
	opacity:1;
    color: rgb(112, 110, 107);
    line-height: 1.25;
    text-align:center;
}
.tablet .forceChatterStyle .cuf-noMore {
	padding:0;
	min-height:0 !important;
	display:none;
}
.carousel:before {
	display:block;
	width:100%;
	content:'Use the menu icon above, or the back arrow to navigate';
	margin-left:20px;
}
.tablet .oneContent {
	/* background:#000 !important;  THIS WILL NEED TO GET REMOVED - IT'S FOR TESTING PURPOSES, might be able to get the header back somewhere around here search for concierge_template in the developer tools */
}
.carousel-body .cuf-feed p span.uiOutputText {
	opacity:0 !important;
	height:1px;
	width:1px;
	display:inline;
}
.uiCarousel .nav-container li:last-child {
	display:none;
}
/*
.tablet .actionButtons {
	display:none !important;
}
.carousel-body .forceChatterRecordFeedContainerMobile  {
	opacity:0;
	height:1px !important;
	height: 1px !important;
	overflow:hidden !important;
	display:inline-block;
}
.carousel-body .forceChatterRecordFeedContainerMobile:before {
	content:'Chatter is currently disabled.';
	display:block;
	opacity:1;
}
.slds-icon-standard-search,
.slds-icon,
.icon,
.search {
	display:none !important;
}*/
.resultsWrapper  {
	display:none;
}


/* INPUT STYLING */
body .container .uiInput--default input, 
body .container input.uiInput--default, 
body .container .uiInput--default textarea, 
body .container textarea.uiInput--default,
body .uiInput--select.select:not([multiple]), 
body .uiInput--select .select:not([multiple]), 
body .uiInput--select .uiPopupTrigger a,
body .table .uiInput--select,
body textarea, 
body textarea.slds-textarea,
body .slds-input {
	height:auto;
    border-radius: 0;
    border: 2px solid #e1e1e1;
	 padding: 5px 14px;
	 font-size:12px;
    line-height: 20px;
    color:#999 !important;
    width:auto;
}
body .slds-select_container .slds-select,
body .slds-select {
	height:auto;
	border-radius: 0;
	border: 2px solid #e1e1e1;
	padding: 5px 14px;
	font-size:12px;
	line-height: 20px;
	color:#999 !important;
	width:100%;
}
div.uiInput--select {
	position:relative;
}
div.uiInput--select label span {
	display:none;
}
.slds-form-element__control .uiInput--select label span {
	display:inline-block;
}
.slds-form-element__control .uiInput--select label:after {
	content:"\f0d7";
	font-family: 'Font Awesome 5 Pro';
	top: 40px;
    z-index: 1;
    width: 7%;
}
.slds-combobox__form-element .slds-button.slds-button_icon.slds-input__icon {
	background:none;
	padding:0;
}
.TABLET .container .panel-header .uiButton--brand{
	color:#fff;
	background:#f68c2c;
}
body .slds-select_container:after {
	content: "\f0d7";
	font-family: 'Font Awesome 5 Pro';
	right: 6px !important;
	top: 18px !important;
	z-index: 1;
	width: 20px !important;
	line-height: 10%;
	position: absolute;
	border-top:none;
	bottom:auto;
}
body .slds-select_container:before {
	content:none;
}
div.uiInput--select label:after {
	content:"\f0d7";
	font-family: 'Font Awesome 5 Pro';
	right:2px;
	top:18px;
	z-index:1;
	width:10%;
	line-height:10%;
	position:absolute;
}
.uiInput--select select:not([multiple]), select.uiInput--select:not([multiple]) {
	background-image:none;
}
body .container input.uiInput--default[disabled] {
	opacity:0.5;
}
body .uiPill--default.pill,
body .slds-box--border {
	border-radius: 0 !important;
    border: 2px solid #e1e1e1;
    color:#999;
}
body .uiPill--default.pill {
	padding: 0 4px;
}
body .uiInput--select.select:not([multiple]), 
body .uiInput--select .select:not([multiple]), 
body .uiInput--select .uiPopupTrigger a {
	width:100%;
}
body .container .uiInput--default input[type="checkbox"],
body .slds-checkbox .slds-checkbox--faux {
    width: 25px;
    height: 25px;
    padding: 0;
    line-height: 100%;
}
body .slds-checkbox .slds-checkbox--faux {
	border:2px solid #e1e1e1;
}
body .uiInput--checkbox input[type=checkbox]:checked, 
body input.uiInput--checkbox[type=checkbox]:checked,
body .slds-checkbox [type=checkbox]:checked + .slds-checkbox--faux:after, 
body .slds-checkbox [type=checkbox]:checked ~ .slds-checkbox--faux:after, 
body .slds-checkbox [type=checkbox]:checked + .slds-checkbox__label .slds-checkbox--faux:after {
    border-bottom: 2px solid rgb(246, 140, 44);
    border-left: 2px solid rgb(246, 140, 44);
}
body .container .uiInput--default input::placeholder, 
body .container input.uiInput--default::placeholder, 
body .container .uiInput--default textarea::placeholder, 
body .container textarea.uiInput--default::placeholder {
	color:#e1e1e1;
	font-size:14px;
}
INPUT::-webkit-input-placeholder, 
INPUT:-moz-placeholder {
    color:#e1e1e1;
}
body input[placeholder], body [placeholder], body *[placeholder] {
	 color:#e1e1e1;
	 font-size:12px;
}
::-webkit-input-placeholder {
    color:#e1e1e1 !important;
}
::-moz-placeholder {
    color:#e1e1e1 !important;
}
::-ms-placeholder {
    color:#e1e1e1 !important;
}
::placeholder {
    color:#e1e1e1 !important;
}
body .container .uiInput--default input:focus, 
body .container input.uiInput--default:focus, 
body .container .uiInput--default textarea:focus, 
body .container textarea.uiInput--default:focus {
	outline:none;
	border-color:#f68c2c !important;
}
body .forceSearchInputLookupDesktop .contentWrapper.focused {
	outline:none;
	border:2px solid #f68c2c !important;
	box-shadow:none;
}
.table td, .table th {
	border-top:1px solid #e8e8e8;
}
.table tr:first-child td {
	border-top:none;
}
tr:active {
	background:#e8e8e8;
}
body .table {
	margin-bottom:0;
}
body .table thead th {
	border-top:none;
	border-bottom: 2px solid #e1e1e1;
}
.table .slds-text-title--caps {
	color:#353534;
	font-size:100%;
	letter-spacing:0;
	font-weight:900;
}
.navCenter ul {
	margin-bottom:0;
}
.slds-brand-band:before {
	background-image:none;
}
body .forcePageBlockItemView {
	border-bottom:none;
}
/* SOME MODAL OVERRIDES */
.slds-clearfix.slds-card.forceDetailPanel {
	padding-bottom:55px;
}
body .slds-modal__container {
	width:100%;
	display:block;
	padding-top:10%;
}
body .slds-modal__header {
	min-height:45px;
}
body .slds-modal__header h4,
body .slds-modal__header h3,
body .slds-modal__header h2 {
	margin-bottom:0;
}
body .uiScrollerWrapper.scrollable, body .modal-body.scrollable {
	max-height:80%;
}

/* MODAL FIXES 6-21-2018 */
.slds-modal__content.slds-p-around--medium.slds-grid.slds-wrap {
	padding-right:25px;
	z-index:99999;
}
body .slds-modal__content {
	min-height:400px;
	max-height:550px;
	overflow-y:scroll !important;
}
.slds-clearfix.slds-card.forceDetailPanel {
	padding-bottom:55px;
}
body .slds-modal__container {
	width:100%;
	display:block;
	padding-top:10%;
}
body .slds-modal__header {
	min-height:45px;
}
body .slds-modal__header h4,
body .slds-modal__header h3,
body .slds-modal__header h2 {
	margin-bottom:0;
}
body .uiScrollerWrapper.scrollable {
	max-height:100%;
}
body .scrollingOnIOS  {
	height:100%;
}
body .slds-modal__container .scrollingOnIOS {
	height:auto;
}
button.slds-button.toastClose.slds-notify__close.slds-button--icon-inverse.slds-button_icon-bare {
	background:transparent !important;
}
body .uiScrollerWrapper.scrollable.scrollingOnIOS>*:not(.skipTransform) {
	-webkit-transform: none !important;
	-ms-transform: none !important;
	transform: none !important;
	user-select: auto !important;
}
body .uiScrollerWrapper.scrollable {
	overflow: scroll !important;
	-webkit-overflow-scrolling: touch !important;
	-webkit-user-drag: auto  !important;
	user-select: auto !important;
}
body .oneMobileWebLayoutContainer .forcePageHost {
	position:relative;
}
body .slds-modal__container .scrollingOnIOS {
	height:550px;
	padding-bottom:75px;
	overflow-x:hidden !important;
}




body .slds-input[placeholder],
body .slds-input:placeholder,
body .slds-input::-webkit-input-placeholder,
body .slds-input::-moz-placeholder,
body .slds-input:-ms-input-placeholder,
body .slds-input:-moz-placeholder {
	color:#999 !important;
	font-size:14px;
}
body .slds-checkbox--faux  {
	border: 2px solid #e1e1e1;
	border-radius:0;
}
.slds-modal__content .slds-input,
.slds-modal__content .slds-select_container .slds-select,
.slds-modal__content .slds-select, 
body .container .forceRecordLayout .input, 
body .container .forceRecordLayout textarea{
	width:100%;
}
.slds-modal__content.slds-p-around--medium.slds-grid.slds-wrap {
	padding-right:25px;
}
.slds-fade-in-open {
    background: rgba(126, 140, 153, 0.8);
}
.forceDetailPanel .uiInput--input.input, 
.forceDetailPanel .uiInput--input .input {
	min-height:auto;
	max-height:auto;
}
label.slds-form-element__label.slds-no-flex,
span.slds-form-element__label,
label.slds-form-element__label {
	color:#999;
}
label.label.inputLabel.uiLabel-left.form-element__label.uiLabel,
label.uiLabel-left.form-element__label.uiLabel,
body .forceDetailPanel .uiInput .form-element__label {
	font-size:14px;
	display:block;
	color:#999;
	font-weight:400;
	line-height:21px;
}
legend.uiLegend-top.form-element__label.uiLegend {
	font-size:14px;
	display:block;
	color:#999;
	font-weight:700;
	line-height:21px;
	margin-top:15px;
	margin-bottom:-5px;
	text-transform:uppercase;
}
.title.slds-text-heading--medium,
span.section-header-title {
	color:#353534;
}
body .slds-theme--shade {
	background-color:transparent;
}
.modal-container .modal-body input[type="text"],
body .modal-container .modal-body textarea {
	width:100%;
}
/* SOME STRANGE MODAL FIXES FOR THE EDIT CUSTOMER MODAL */
body .slds-modal__container {
	width:100%;
}
div.modal-body.scrollable.slds-modal__content.slds-p-around--medium {
	box-shadow:none;
	padding:0;
}
div.modal-body.scrollable.slds-modal__content.slds-p-around--medium .slds-clearfix.slds-card.forceDetailPanel {
	border-radius:0;
}
button.slds-button.slds-button--brand {
	border-radius:0;
	border:none;
	color:#fff;
	background:#f68c2c;
	padding:10px 16px;
	line-height:14px;
	font-size:12px;
	cursor:pointer;
}
button.slds-button.slds-button--brand:hover {
	background:#e27b1d;
}
/* should not need this 6/25/2018
button.slds-button.slds-button--neutral {
	border-radius:0;
	border:none;
	color:#fff;
	background:#999;
	padding:10px 16px;
	line-height:14px;
	font-size:12px;
	cursor:pointer;
}
button.slds-button.slds-button--neutral:hover {
	background:#868686;
}*/
.toastContainer {
	z-index:999999;
}
body .uiMenuList--default .uiMenuItem>a, 
body .uiMenuList--default .uiMenuItem>span {
	color:#3366cc;
}
/* MODAL FORM SPECIFIC */
.modal-body .slds-grid.full.forcePageBlockSectionRow {
	margin-bottom:15px;
}
body .modal-body .uiInput--checkbox input[type=checkbox] {
	margin-bottom:15px;
}
body .slds-text-color--default {
	color:#353534;
}
body .slds-text-color--weak {
	color:#999;
}


/* MOBILE MODAL STYLING */
body .forceMobileOverlay .container {
	max-width:100%;
}
.forcePageBlockSection .section-header-title {
	font-size:16px;
	letter-spacing:1px;
	font-weight:bold;
	margin-left:15px;
}
.cardWrapper .forcePageBlockSection .section-header-title {
	margin-left:0;
}
h3.slds-section__title.slds-theme--shade.primaryPaletteBorder.test-id__section-header-container {
	padding-top:15px;
}
.forceRecordLayout .slds-is-open .slds-grid.full.forcePageBlockSectionRow {
	margin-bottom:15px;
}
.forceMobileOverlay .forceRecordLayout input[type="text"],
.forceMobileOverlay .forceRecordLayout input.input,
.forceMobileOverlay .forceRecordLayout textarea,
.forceMobileOverlay .forceRecordLayout select {
	width:100% !important;
	color:#353534 !important;
}
.slds-clearfix.slds-card.forceDetailPanel {
	padding-right:20px;
	margin-bottom:0;
}
body div.forceInputLookupTrigger a.searchOrClear {
	line-height:35px;
}
.forceInputLookupPanel .forceInputLookupPanelSelector .select.uiInput.uiInputSelect.uiInput--default.uiInput--select {
	height:auto;
}
.eIcon.forceEntityIcon {
	display:none;
}
.forceInputLookupPanel .searchBox a.searchOrClear {
	top:3px;
}
.forceMobileOverlay .panel-content .forceInputLookupPanel .searchBox input.input {
	width:100%;
}
.forceMobileOverlay .forceInputLookupPanelSelector .selected {
	padding:5px 10px 15px;
}
.forceMobileOverlay li.slds-p-around--small.panelItem.slds-item {
	padding:5px 20px;
}
.slds-has-flexi-truncate.slds-p-horizontal_small.full.blank.forcePageBlockItem.forcePageBlockItemView {
	display:none;
}
.forceMobileOverlay .forceIcon.slds-button__icon .slds-icon {
	color:#3366cc;
	fill:#3366cc;
}




/* SLDS PADDING OVERRIDES */
body .slds-p-vertical_xx-small, 
body .slds-p-vertical--xx-small,
body .slds-p-horizontal_small, 
body .slds-p-horizontal--small,
body .slds-p-horizontal_x-small, 
body .slds-p-horizontal--x-small {
	padding:0;
}


/* TESTING CAROUSEL */
.slider{
	width: 100%; /*Same as width of the large image*/
	position: relative;
	padding-top: 290px; /*That helps bring the labels down*/
	margin: 0 auto 115px auto;
}


/* Last thing remaining is to add transitions KJASd9jdA(!E@#$ */
.slider>img{
	position: absolute;
	left: 0; top: 0;
	transition: all 0.5s;
}

.slider input[name='slide_switch'] {
	display: none;
}

.slider label {
	/*Lets add some spacing for the thumbnails*/
	margin: 18px 8px 0 0;
	border: 3px solid #999;
	
	float: left;
	cursor: pointer;
	transition: all 0.5s;
	
	/*Default style = low opacity*/
	opacity: 0.6;
}
.slider label.thumbWrapper:first-child {
	margin-left:0;
}
.slider label.thumbWrapper:last-child {
	margin-right:0;
}

.slider label img{
	display: block;
}

/*Time to add the click effects*/
.slider input[name='slide_switch']:checked+label {
	border-color: #666;
	opacity: 1;
}
/*Clicking any thumbnail now should change its opacity(style)*/
/*Time to work on the main images*/
.slider input[name='slide_switch'] ~ img {
	opacity: 0;
	transform: scale(1.1);
}
/*That hides all main images at a 110% size
On click the images will be displayed at normal size to complete the effect
*/
.slider input[name='slide_switch']:checked+label+img {
	opacity: 1;
	transform: scale(1);
}
/*Clicking on any thumbnail now should activate the image related to it*/
.thumbCarouselWrapper {
  overflow-x:scroll;
  overflow-y:hidden;
  -webkit-overflow-scrolling:touch;
  width:345px;
  white-space:nowrap;
  word-wrap: none;
}

.largeImage {
	max-width:345px;
	position:fixed;
	scroll-behavior:none;
}
.thumbWrapper {
	display:inline-block;
}




/* CSS used here will be applied after bootstrap.css */
.carousel {
    margin-top: 20px;
}
.item .thumb {
	width: 25%;
	cursor: pointer;
	float: left;
}
.item .thumb img {
	width: 100%;
	margin: 2px;
}
.item img {
	width: 100%;	
}