import Foundation
import SlackKit
import HTTPServer

var _channel = ""

class SlackWebhookGateway: MessageEventsDelegate {
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
        co { [weak self]() in
            self?.client.connect()
        }
    }
 

    // MARK: MessageEventsDelegate
    func received(_ message: SlackKit.Message, client: SlackClient) {
        if let id = client.authenticatedUser?.id {
            if message.text?.contains(id) == true {
                handleMessage(message: message)
            }
        }
    }
    func changed(_ message: SlackKit.Message, client: SlackClient) {}
    func deleted(_ message: SlackKit.Message?, client: SlackClient) {}
    func sent(_ message: SlackKit.Message, client: SlackClient) {}

    private func handleMessage(message: SlackKit.Message) {
        if let _ = message.text, let channel = message.channel {
            _channel = channel
             client.webAPI.sendMessage(channel: channel, text: "Botson Response1", username: nil, asUser: nil, parse: nil, linkNames: nil,
                                       attachments: nil, unfurlLinks: nil, unfurlMedia: nil, iconURL: nil, iconEmoji: nil, 
                                       success: nil, failure: nil) 
        }
    }
}

let slackbot = SlackWebhookGateway(token: Configuration.slackBotToken)
let log = LogMiddleware()

let router = BasicRouter { route in
    route.get("/responde") { request in
    slackbot.client.webAPI.sendMessage(channel: _channel, text: "Botson Response2", username: nil, asUser: nil, parse: nil, linkNames: nil,
                                       attachments: nil, unfurlLinks: nil, unfurlMedia: nil, iconURL: nil, iconEmoji: nil,
                                       success: nil, failure: nil)
        
        
        return Response(body: "Responding to Slack!")
    }
}

let server = try Server(port: 8081, middleware: [log], responder: router)
try server.start()
