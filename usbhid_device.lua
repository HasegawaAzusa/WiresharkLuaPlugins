local mapping_value_tab = require('data/mapping_value_tab')

--------------------------------------------------------------------------------
-- USB HID MOUSE PROTOCOL                                                     --
--------------------------------------------------------------------------------
local button_value_tab = {
    [0x00] = "Move",
    [0x01] = "Left",
    [0x02] = "Right",
    [0x04] = "Middle",
    [0x08] = "Back",
    [0x10] = "Forward",
    [0x20] = "Switch"
}

-- Define Protocol
local usbhid_mouse_protocol = Proto.new("usbhid_mouse", "USB HID Mouse")

-- Define Protocol Fields
local button_field = ProtoField.uint8("usbhid_mouse.button", "Button", base.DEC, button_value_tab)
local reversed_field = ProtoField.uint8("usbhid_mouse.reversed", "Reversed", base.DEC)
local offset_x_field = ProtoField.int16("usbhid_mouse.offset_x", "Offset X", base.DEC)
local offset_y_field = ProtoField.int16("usbhid_mouse.offset_Y", "Offset Y", base.DEC)
local vertical_scrolling_field = ProtoField.int16(
    "usbhid_mouse.vertical_scrolling",
    "Vertical Scrolling", base.DEC
)
local horizontal_scrolling_field = ProtoField.int16(
    "usbhid_mouse.horizontal_scrolling",
    "Horizontal Scrolling", base.DEC
)
usbhid_mouse_protocol.fields = {
    button_field,
    reversed_field,
    offset_x_field,
    offset_y_field,
    vertical_scrolling_field,
    horizontal_scrolling_field
}

function usbhid_mouse_protocol.dissector(tvb, pinfo, tree)
    local length = tvb:captured_len()
    if length == 4 then
        local subtree = tree:add(usbhid_mouse_protocol, tvb(), "USB HID Mouse")
        subtree:add_le(button_field, tvb(0, 1))
        subtree:add_le(offset_x_field, tvb(1, 1))
        subtree:add_le(offset_y_field, tvb(2, 1))
        subtree:add_le(vertical_scrolling_field, tvb(3, 1))
    elseif length == 8 then
        local subtree = tree:add(usbhid_mouse_protocol, tvb(), "USB HID Mouse")
        subtree:add_le(button_field, tvb(0, 1))
        subtree:add_le(reversed_field, tvb(1, 1))
        subtree:add_le(offset_x_field, tvb(2, 2))
        subtree:add_le(offset_y_field, tvb(4, 2))
        subtree:add_le(vertical_scrolling_field, tvb(6, 1))
        subtree:add_le(horizontal_scrolling_field, tvb(7, 1))
    end
end

--------------------------------------------------------------------------------
-- USB HID KEYBOARD PROTOCOL                                                  --
--------------------------------------------------------------------------------
local modifier_button_tab = {
    [0x00] = "None",
    [0x01] = "Left Control",
    [0x02] = "Left Shift",
    [0x04] = "Left Alt",
    [0x08] = "Left Meta",
    [0x10] = "Right Control",
    [0x20] = "Right Shift",
    [0x40] = "Right Alt",
    [0x80] = "Right Meta"
}

-- Define Protocol
local usbhid_keyboard_protocol = Proto.new("usbhid_keyboard", "USB HID Keyboard")

-- Define Protocol Fields
local modifier_field = ProtoField.uint8("usbhid_keyboard.modifier", "Modifier", base.DEC, modifier_button_tab)
local reversed_field = ProtoField.uint8("usbhid_keyboard.reversed", "Reversed", base.DEC)
local mapping1_field = ProtoField.uint8("usbhid_keyboard.mapping1", "Mapping 1", base.DEC, mapping_value_tab)
local mapping2_field = ProtoField.uint8("usbhid_keyboard.mapping2", "Mapping 2", base.DEC, mapping_value_tab)
local mapping3_field = ProtoField.uint8("usbhid_keyboard.mapping3", "Mapping 3", base.DEC, mapping_value_tab)
local mapping4_field = ProtoField.uint8("usbhid_keyboard.mapping4", "Mapping 4", base.DEC, mapping_value_tab)
local mapping5_field = ProtoField.uint8("usbhid_keyboard.mapping5", "Mapping 5", base.DEC, mapping_value_tab)
local mapping6_field = ProtoField.uint8("usbhid_keyboard.mapping6", "Mapping 6", base.DEC, mapping_value_tab)
usbhid_keyboard_protocol.fields = {
    modifier_field,
    reversed_field,
    mapping1_field,
    mapping2_field,
    mapping3_field,
    mapping4_field,
    mapping5_field,
    mapping6_field,
}

function usbhid_keyboard_protocol.dissector(tvb, pinfo, tree)
    local length = tvb:captured_len()
    if length == 8 then
        local subtree = tree:add(usbhid_mouse_protocol, tvb(), "USB HID Keyboard")
        subtree:add_le(modifier_field, tvb(0, 1))
        subtree:add_le(reversed_field, tvb(1, 1))
        subtree:add_le(mapping1_field, tvb(2, 1))
        subtree:add_le(mapping2_field, tvb(3, 1))
        subtree:add_le(mapping3_field, tvb(4, 1))
        subtree:add_le(mapping4_field, tvb(5, 1))
        subtree:add_le(mapping5_field, tvb(6, 1))
        subtree:add_le(mapping6_field, tvb(7, 1))
    end
end

--------------------------------------------------------------------------------
-- USB HID DEVICE PROTOCOL                                                    --
--------------------------------------------------------------------------------

-- Define Protocol
local usbhid_device_protocol = Proto.new("usbhid_device", "USB HID Device")

-- Define Protocol Fields
local origin_data_field = ProtoField.bytes("usbhid_device.hid_data", "HID Data")
usbhid_device_protocol.fields = {
    origin_data_field
}

function usbhid_device_protocol.dissector(tvb, pinfo, tree)
    local length = tvb:captured_len()
    if length == 0 then
        return
    end
    local subtree = tree:add(usbhid_device_protocol, tvb(), "USB HID Device")
    subtree:add_le(origin_data_field, tvb())
    usbhid_mouse_protocol.dissector(tvb, pinfo, subtree)
    usbhid_keyboard_protocol.dissector(tvb, pinfo, subtree)
end

DissectorTable.get("usb.interrupt"):add(0xffff, usbhid_device_protocol)