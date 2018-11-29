.search-result-wrapper {
	position: relative;
}
.search-result-wrapper-inline {
	display: inline-block;
}
.search-result-wrapper ul.searchResults {
	background: #fff;
	border: 2px solid #e1e1e1;
	border-top: none;
	-moz-border-radius-bottomright: 5px;
	-moz-border-radius-bottomleft: 5px;
	border-bottom-right-radius: 5px;
	border-bottom-left-radius: 5px;
	color: #16325c;
	min-height: calc(2.125rem + 2px);
	max-height: 500px;
	overflow-y: auto;
	padding: 0 0 8px 0;
	position: absolute;
	top: 35px;
	left: 0;
	-webkit-transition: border .1s linear, background-color .1s linear;
	transition: border .1s linear, background-color .1s linear;
	width: 100%;
	z-index: 5;
}
.search-result-wrapper-wider ul.searchResults {
	top: 55px;
}
.search-result-wrapper ul.searchResults li {
	line-height: 20px;
}
.search-result-wrapper ul.searchResults li a {
	display: block;
	line-height: 22px;
	padding:3px 1rem 3px .75rem;
}
.search-result-wrapper ul.searchResults li a:hover, 
.search-result-wrapper ul.searchResults li a:focus, 
.search-result-wrapper ul.searchResults li:focus, 
.search-result-wrapper ul.searchResults li a:active {
	background: #f4f6f9;
	color: #334056;
	text-decoration: none;
}
.search-result-wrapper .spinner-inner {
	float: right;
	margin-right: -15px;
	margin-top: 16px;
	position: relative;
}
.search-result-wrapper-wider .spinner-inner {
	margin-top: -18px;
}