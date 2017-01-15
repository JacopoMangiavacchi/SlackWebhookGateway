import Foundation
import SlackKit
import HTTPServer

var _channel = ""

class SlackWebhookGateway: MessageEventsDelegate {
    let client: SlackClient
    
    init(token: String) {
        client = SlackClient(apiToken: token)
        client.messageEventsDelegate = self
    }
    
    // MARK: MessageEventsDelegate
    func received(_ message: SlackMessage, client: SlackClient) {
        if let id = client.authenticatedUser?.id {
            if message.text?.contains(id) == true {
                handleMessage(message: message)
            }
        }
    }
    func changed(_ message: SlackMessage, client: SlackClient) {}
    func deleted(_ message: SlackMessage?, client: SlackClient) {}
    func sent(_ message: SlackMessage, client: SlackClient) {}

    func notified(_ content: String, channel: String, client: SlackClient) {

    }
    
    private func handleMessage(message: SlackMessage) {
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
let server = try Server(port: 8080, middleware: [log], responder: router)

let serialQueue = DispatchQueue(label: "SlackQueue", qos: .background, attributes: [], autoreleaseFrequency: .inherit, target: nil)

serialQueue.async {
    slackbot.client.connect()
}

try server.start()

