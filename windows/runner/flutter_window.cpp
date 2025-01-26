#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <optional>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include "flutter/generated_plugin_registrant.h"

#include "utils.h"
#include <vector>
#include <string>
#include <iostream>

int CALLBACK EnumFontProc(const LOGFONTW *lpelfe, const TEXTMETRICW *lpntme, DWORD FontType, LPARAM lParam)
{
    std::vector<std::string> *fonts = reinterpret_cast<std::vector<std::string> *>(lParam);

    // Converte o nome da fonte de wstring para string (UTF-8)
    std::wstring fontName(lpelfe->lfFaceName, wcslen(lpelfe->lfFaceName));

    int bufferSize = WideCharToMultiByte(CP_UTF8, 0, fontName.c_str(), -1, NULL, 0, NULL, NULL);
    std::vector<char> buffer(bufferSize);

    WideCharToMultiByte(CP_UTF8, 0, fontName.c_str(), -1, buffer.data(), bufferSize, NULL, NULL);

    fonts->push_back(std::string(buffer.begin(), buffer.end() - 1)); // Remove o caractere nulo

    return 1; // Continua a enumeração
}

std::vector<std::string> getInstalledFonts()
{
    std::vector<std::string> fontNames;

    LOGFONTW logFont = {0}; // Inicializa a estrutura LOGFONTW com 0

    HDC hdc = GetDC(NULL); // Obtenha o contexto de dispositivo da tela
    if (hdc) {
        EnumFontFamiliesExW(hdc, &logFont, EnumFontProc, reinterpret_cast<LPARAM>(&fontNames), 0);
        ReleaseDC(NULL, hdc); // Libere o contexto de dispositivo após o uso
    }

    return fontNames;
}

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate()
{
    if (!Win32Window::OnCreate())
    {
        return false;
    }

    RECT frame = GetClientArea();

    flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
        frame.right - frame.left, frame.bottom - frame.top, project_);

    if (!flutter_controller_->engine() || !flutter_controller_->view())
    {
        return false;
    }

    // Registre o canal após inicializar o flutter_controller_
    flutter::MethodChannel<> channel(
        flutter_controller_->engine()->messenger(), "kanjilogia/fonts",
        &flutter::StandardMethodCodec::GetInstance());
    channel.SetMethodCallHandler(
    [](const flutter::MethodCall<>& call,
        std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "fonts") {
            std::vector<std::string> fonts = getInstalledFonts();
            
            // Convierte std::vector<std::string> a flutter::EncodableList
            flutter::EncodableList encodable_fonts;
            for (const auto& font : fonts) {
                encodable_fonts.push_back(font); // std::string se convierte automáticamente a EncodableValue
            }

            // Devuelve la lista codificada
            result->Success(encodable_fonts);
        }
    });


    RegisterPlugins(flutter_controller_->engine());
    SetChildContent(flutter_controller_->view()->GetNativeWindow());

    flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                        { this->Show(); });
    flutter_controller_->ForceRedraw();

    return true;
}

void FlutterWindow::OnDestroy()
{
    if (flutter_controller_)
    {
        flutter_controller_ = nullptr;
    }

    Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept
{
    if (flutter_controller_)
    {
        std::optional<LRESULT> result =
            flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                          lparam);
        if (result)
        {
            return *result;
        }
    }

    switch (message)
    {
    case WM_FONTCHANGE:
        if (flutter_controller_) {
            flutter_controller_->engine()->ReloadSystemFonts();
        }
        break;
    }

    return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
