<!doctype html>
<html lang="en">
  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="custom.css">
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
	<title>Mental Health Assistant</title>
	<script type="text/javascript">
		var accessToken = "b32250b5d97f45118abbf80529249863";
		var baseUrl = "https://api.api.ai/v1/";

		$(document).ready(function() 
		{
		
			$('.hide-chat-box').click(function()
			{
					$('.chat-content').slideToggle();
					$('#minimize-icon').toggle();
					$('#maximize-icon').toggle();
			});
			
			$("#input").keypress(function(event) {
				if (event.which == 13) {
					event.preventDefault();
					send();
				}
			});
			$("#rec").click(function(event) {
				switchRecognition();
			});
		});

		var recognition;

		function startRecognition() {
			recognition = new webkitSpeechRecognition();
			recognition.onstart = function(event) {
				updateRec();
			};
			recognition.onresult = function(event) {
				var text = "";
			    for (var i = event.resultIndex; i < event.results.length; ++i) {
			    	text += event.results[i][0].transcript;
			    }
			    setInput(text);
				stopRecognition();
			};
			recognition.onend = function() {
				stopRecognition();
			};
			recognition.lang = "en-US";
			recognition.start();
		}
	
		function stopRecognition() {
			if (recognition) {
				recognition.stop();
				recognition = null;
			}
			updateRec();
		}

		function switchRecognition() {
			if (recognition) {
				stopRecognition();
			} else {
				startRecognition();
			}
		}

		function setInput(text) 
		{
			$(".btn-xs").attr("disabled", true);
			$("#input").val(text);
			sendReply();
		}

		function updateRec() {
			$("#rec").text(recognition ? "Stop" : "Speak");
		}

		
		function send() 
		{
			var text = $("#input").val();
			setResponse("<li class='pl-2 pr-2 bg-primary rounded text-white text-center send-msg mb-1'>"+
                                text+"</li>");
			sendReply();
		}
		
		function sendReply() 
		{
			var text = $("#input").val();
			$("#input").val("");
			$.ajax({
				type: "POST",
				url: baseUrl + "query?v=20150910",
				contentType: "application/json; charset=utf-8",
				dataType: "json",
				headers: {
					"Authorization": "Bearer " + accessToken
				},
				data: JSON.stringify({ query: text, lang: "en", sessionId: "somerandomthing" }),

				success: function(data) {
					//setResponse(JSON.stringify(data, undefined, 2));
					//setResponse("Bot: " + data.result.fulfillment.speech);
					var output = data.result.fulfillment.speech;
					if(output.localeCompare('button')==0)
					{
					var buttonClick = 'setInput("next")';
					var totalMessages = Object.keys(data.result.fulfillment.messages).length;
					var responseMessage = "<li class='p-1 rounded mb-1'>"+
											"<div class='receive-msg'>"+
											"    <img src='https://storage.googleapis.com/cloudprod-apiai/0f875a80-b955-4301-8260-24f6e34c3c02_l.png'>"+
											"<div class='container-fluid'>"+
											"  <div class='row'>";

					for ( var i = 0; i < totalMessages; i++)
					{
						var type = JSON.stringify(data.result.fulfillment.messages[i].type);
						var val = JSON.stringify(data.result.fulfillment.messages[i].textToSpeech);
						if(type.includes('simple_response')&&!val.includes('"button"'))
						{
						responseMessage = responseMessage +	"    <div class='col-sm-12 rcorners'>"+data.result.fulfillment.messages[i].textToSpeech+"</div>";
						}
					}
					responseMessage = responseMessage +	"  </div>";

					for ( var i = 0; i < totalMessages; i++)
					{
						var message =data.result.fulfillment.messages[i];
						var type = JSON.stringify(message.type);
						var val = JSON.stringify(message.textToSpeech);
						if(type.includes('suggestion_chips'))
						{
							for (var key in message.suggestions) 
							{
								if (message.suggestions.hasOwnProperty(key)) 
								{
									var val = message.suggestions[key];
							var buttons =	"  <div class='row'>"+
											"    <div class='col-sm-6'><button type='button' onclick="+buttonClick+" class='btn btn-xs  btn-block btn-success'>"+val.title+
											"</button></div>"+
											"  </div>";
							responseMessage = responseMessage + buttons;
								}
							}
						}
					}
					responseMessage =	responseMessage + 
											"</div>"+
											"</div>"+
										"</li>";
					setResponse(responseMessage);
					}
					else
					setResponse("<li class='p-1 rounded mb-1'>"+
                                "<div class='receive-msg'>"+
                                "    <img src='https://storage.googleapis.com/cloudprod-apiai/0f875a80-b955-4301-8260-24f6e34c3c02_l.png'>"+
                                "    <div class='receive-msg-desc  text-center mt-1 ml-1 pl-2 pr-2'>"+
                                "        <p class='pl-2 pr-2 rounded'>"+output+"</p>"+
                                "    </div>"+
                                "</div>"+
                            "</li>");
				},
				error: function() {
					setResponse("<li class='p-1 rounded mb-1'>"+
                                "<div class='receive-msg'>"+
                                "    <div class='receive-msg-desc  text-center mt-1 ml-1 pl-2 pr-2'>"+
                                "        <p class='pl-2 pr-2 rounded' style='color:red'>Internal Server Error</p>"+
                                "    </div>"+
                                "</div>"+
                            "</li>");
				}
			});
		}

		function setResponse(val) {
			$("#response").append(val);
		}

	</script>
  </head>
  <body>
    <div class="container">
        <div class="row pt-3">
            <div class="chat-main">
                <div class="col-md-12 chat-header rounded-top bg-primary text-white">
                    <div class="row">
                        <div class="col-md-10 username pl-2">
                            <i class="fa fa-circle text-success" aria-hidden="true"></i>
                            <h6 class="m-0">Mental Health Assistant</h6>
                        </div>
                        <div class="col-md-2 options text-right pr-2">
                            <i id="minimize-icon" class="fa fa-window-minimize hide-chat-box" aria-hidden="true"></i>
                            <i id="maximize-icon" style="display: none;" class="fa fa-window-maximize hide-chat-box" aria-hidden="true"></i>
                          </div>
                    </div>
                </div>
                <div class="chat-content">
                    <div class="col-md-12 chats border">
                        <ul id="response" class="p-0">
                        </ul>
                    </div>
                    <div class="col-md-12 message-box border pl-2 pr-2 border-top-0">
                        <input id="input" type="text" class="pl-0 pr-0 w-100" placeholder="Type a message..." />
                        <div class="tools">
                            <i class="fa fa-picture-o" aria-hidden="true"></i>
                            <i class="fa fa-bell" aria-hidden="true"></i>
                            <i class="fa fa-meh-o" aria-hidden="true"></i>
                            <i class="fa fa-paperclip" aria-hidden="true"></i>
                            <i class="fa fa-camera" aria-hidden="true"></i>
                            <i class="fa fa-thumbs-o-up m-0" aria-hidden="true"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
  </body>
</html>
