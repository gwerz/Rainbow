/*
 *  recovery.h
 *  iusbcomm
 *
 *  Created by John Heaton on 5/16/10.
 *  Copyright 2010 Gojohnnyboi. All rights reserved.
 *
 */

#ifndef IUSBCOMM_RECOVERY_H
#define IUSBCOMM_RECOVERY_H

#include <CoreFoundation/CoreFoundation.h>

typedef struct __iUSBRecoveryDevice *iUSBRecoveryDeviceRef;

/*!
 @enum iUSBPID
 @field kUSBPIDRecovery - the idProduct for recovery mode
 @field kUSBPIDDFU - the idProduct for dfu mode(older devices)
 @field kUSBPIDWTF - the idProduct for dfu mode(newer devices)
 */
enum iUSBPID {
	kUSBPIDRecovery = 0x1281,
	kUSBPIDDFU = 0x1222,
	kUSBPIDWTF = 0x1227
};

/*!
 @enum iUSBRecoveryConnectionState
 @field kUSBConnected - device is in a connected state
 @field kUSBDisconnected - device is disconnected
 */
enum iUSBRecoveryConnectionState {
	kUSBConnected = 0xA,
	kUSBDisconnected = 0xB
};

/*!
 @typedef iUSBRecoveryDeviceTransferProgressCallback
 @param percentComplete - The percent of the transfer complete
*/
typedef void (*iUSBRecoveryDeviceTransferProgressCallback)(Float32 percentComplete);

/*!
 @typedef iUSBRecoveryDeviceConnectionChangeCallback
 @param device - The device whose state has changed
 @param newConnectionState - The new state of the connection. See @enum iUSBRecoveryConnectionState
 */
typedef void (*iUSBRecoveryDeviceConnectionChangeCallback)(iUSBRecoveryDeviceRef device, uint8_t newConnectionState);

/*!
 @struct iUSBRecoveryDeviceNotificationContext
 @field disconnectCallback - The callback that will be called when the device disconnects. Must be non-NULL
 @field runLoop - Optional. The run loop to add the notification to. If NULL, will assume CFRunLoopGetCurrent()
 @field runLoopMode - Optional. The run loop mode for the run loop to add notifications to. If NULL, 
 will assume kCFRunLoopDefaultMode
 */
typedef struct {
	iUSBRecoveryDeviceConnectionChangeCallback disconnectCallback;
	CFRunLoopRef runLoop;
	CFStringRef runLoopMode;
} iUSBRecoveryDeviceNotificationContext;

/*!
 @function iUSBRecoveryDeviceCreateWithPID
 Enumerates all connected devices, searching for one that has a matching idProduct value.
 @param pid - The idProduct value to compare while enumerating devices. 
 Note that the idVendor value will always be set to 0x5AC(Apple Inc.)
 @param context - The optional notification context for disconnect notifications.
 @result If pid was matched with a device's idProduct field, an iUSBRecoveryDeviceRef object 
 will be returned. If no idProduct was matched, the result will be NULL.
 */
iUSBRecoveryDeviceRef iUSBRecoveryDeviceCreate(uint16_t pid, iUSBRecoveryDeviceNotificationContext *context);

/*!
 @function iUSBRecoveryDeviceRelease
 Safely disconnects and deallocates the device object
 @param device - The device to deallocate.
 */
void iUSBRecoveryDeviceRelease(iUSBRecoveryDeviceRef device);

/*!
 @function iUSBRecoveryDeviceGetPID
 Returns the PID of the device given.
 @param device - The device to return the idProduct field of.
 @result The idProduct of the given device.
 */
uint16_t iUSBRecoveryDeviceGetPID(iUSBRecoveryDeviceRef device);

/*!
 @function iUSBRecoveryDeviceSendCommand
 Sends a command to iBoot/iBEC/iBSS on the device in recovery mode.
 @param device - The device to send the command to. Must be a device in recovery mode.
 @param command - The command to send.
 @result A boolean value, stating whether the command was sent, and there was no error.
 Note: a false value will be returned if the command syntax was incorrect, or if the command
 sent turns off/reboots the device.
 */
Boolean iUSBRecoveryDeviceSendCommand(iUSBRecoveryDeviceRef device, CFStringRef command);

/*!
 @function iUSBRecoveryDeviceSendFile
 Sends a file to a recovery/dfu mode device.
 @param device - The device to send the file to. May be in recovery or dfu mode.
 @param file - The file to send.
 @param progressCallback - Optional. A callback function that progress will be sent to.
 @result A boolean value, stating whether the file was sent.
 */
Boolean iUSBRecoveryDeviceSendFile(iUSBRecoveryDeviceRef device, CFStringRef filePath, iUSBRecoveryDeviceTransferProgressCallback progressCallback);

/*!
 @function iUSBRecoveryDeviceReadResponse
 Read a response message from iBoot/iBEC/iBSS from a device in recovery mode.
 @param device - The device to send the file to. Must be in recovery mode.
 @param noDataTimeout - Specifies a time value in milliseconds. Once the request is queued on 
 the bus, if no data is transferred in this amount of time, the request will be aborted and returned.
 @param completionTimeout - Specifies a time value in milliseconds. Once the request is queued on 
 the bus, if the entire request is not completed in this amount of time, the request will be aborted and returned.
 @result A CFStringRef object which is the response string. The caller is responsible for deallocating this.
 */
CFStringRef iUSBRecoveryDeviceReadResponse(iUSBRecoveryDeviceRef device, UInt32 noDataTimeout, UInt32 completionTimout);

/*!
 @function iUSBRecoveryDeviceSendControlMessage
 Send a message via the device control pipe.
 @param device - The device to send the message to.
 @param the rest of the parameters are those of the usb request.
 @result A boolean value, stating whether the message was sent successfully.
 */
Boolean iUSBRecoveryDeviceSendControlMessage(iUSBRecoveryDeviceRef device, UInt8 bmRequestType, UInt8 bRequest, UInt16 wValue, UInt16 wIndex, UInt16 wLength, void *pData, UInt32 wLenDone);

/*!
 @function iUSBRecoveryDeviceIsInRecoveryMode
 Check if the given device is in recovery mode.
 @param device - The device to query the mode of.
 @result A boolean value, stating whether the device is in recovery mode.
 */
Boolean iUSBRecoveryDeviceIsInRecoveryMode(iUSBRecoveryDeviceRef device);

/*!
 @function iUSBRecoveryDeviceReboot
 Reboot the device
 @param device - The device to reboot.
 */
void iUSBRecoveryDeviceReboot(iUSBRecoveryDeviceRef device);

/*!
 @function iUSBRecoveryDeviceSetAutoBoot
 Change whether the device boots into the OS regularly each boot.
 @param device - The device to change the boot configuration of.
 @param autoBoot - A boolean value, stating whether or not the device should boot into the OS.
 */
void iUSBRecoveryDeviceSetAutoBoot(iUSBRecoveryDeviceRef device, Boolean autoBoot);

#endif /* IUSBCOMM_RECOVERY_H */