package com.example.brt;

import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.Layout;
import android.text.TextPaint;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Observer;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.cie.btp.Barcode;
import com.cie.btp.CieBluetoothPrinter;
import com.cie.btp.DebugLog;
import com.cie.btp.FontStyle;
import com.cie.btp.FontType;
import com.cie.btp.PrintColumnParam;
import com.cie.btp.PrintImageColumn;
import com.cie.btp.PrinterWidth;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_CONN_DEVICE_NAME;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_CONN_STATE_CONNECTED;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_CONN_STATE_CONNECTING;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_CONN_STATE_LISTEN;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_CONN_STATE_NONE;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_MSG;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_NOTIFICATION_ERROR_MSG;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_STATUS;
import static com.cie.btp.BtpConsts.RECEIPT_PRINTER_MESSAGES;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "brother/print";
    public CieBluetoothPrinter mPrinter = CieBluetoothPrinter.INSTANCE;

    ProgressDialog pdWorkInProgress;
    private static final int BARCODE_WIDTH = 384;
    private static final int BARCODE_HEIGHT = 100;
    private static final int QRCODE_WIDTH = 150;
    private int imageAlignment = 1;
    private int results;

    private String name;
    private String time;
    private String date;
    private String number;
    private boolean isFineTicket = false;
    private String phoneNumber;
    private String checkPost;
    private String fine;
    private String violation;
    private String ticketContent;
    private String utrId;
    public static final String STREAM = "printingStatus";
    EventChannel.EventSink mEventSink;


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), STREAM).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                mEventSink = events;


            }

            @Override
            public void onCancel(Object arguments) {
                mEventSink = null;
            }
        });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("select")) {

                                mPrinter.disconnectFromPrinter();

                                mPrinter.selectPrinter(MainActivity.this);
                            } else if (call.method.equals("print")) {
                                mPrinter.connectToPrinter();
                                name = call.argument("Name");
                                time = call.argument("time");
                                date = call.argument("date");
                                number = call.argument("number");
                                isFineTicket = call.argument("isFineTicket");
                                phoneNumber = call.argument("phone");
                                checkPost = call.argument("checkPost");
                                violation = call.argument("violation");
                                fine = call.argument("fine");
                                ticketContent = call.argument("ticketMap");
                                utrId = call.argument("utrId");


                                // Toast.makeText(this, "Bluetooth Not Supported", Toast.LENGTH_SHORT).show();
                            } else if (call.method.equals("printerStatus")) {

                                result.success(results);

                            }
                        }
                );
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
       pdWorkInProgress = new ProgressDialog(this);
       BluetoothAdapter mAdapter = BluetoothAdapter.getDefaultAdapter();
       if (mAdapter == null) {
           Toast.makeText(this, "Bluetooth Not Supported", Toast.LENGTH_SHORT).show();
           finish();
       }
       try {
           mPrinter.initService(MainActivity.this);
       } catch (Exception e) {
           e.printStackTrace();
       }
    }

    @Override
    protected void onResume() {
        mPrinter.onActivityResume();
        super.onResume();
    }

    @Override
    protected void onPause() {
        mPrinter.onActivityPause();
        super.onPause();
    }

    @Override
    protected void onStart() {
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(RECEIPT_PRINTER_MESSAGES);
        LocalBroadcastManager.getInstance(this).registerReceiver(ReceiptPrinterMessageReceiver, intentFilter);

        super.onStart();
    }

    @Override
    protected void onStop() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(ReceiptPrinterMessageReceiver);

        super.onStop();
    }

    @Override
    protected void onDestroy() {
        DebugLog.logTrace("onDestroy");
        mPrinter.onActivityDestroy();
        super.onDestroy();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        mPrinter.onActivityRequestPermissionsResult(requestCode, permissions, grantResults);
    }

  

    private final BroadcastReceiver ReceiptPrinterMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            DebugLog.logTrace("Printer Message Received");
            Bundle b = intent.getExtras();
            if (b == null) {
                return;
            }
            results = b.getInt(RECEIPT_PRINTER_STATUS);
            mEventSink.success(results);
            switch (b.getInt(RECEIPT_PRINTER_STATUS)) {

                case RECEIPT_PRINTER_CONN_STATE_NONE:
                    Log.d("Not Connected", "");
                    break;
                case RECEIPT_PRINTER_CONN_STATE_LISTEN:
                    Log.d("Ready to connect", "");
                    break;
                case RECEIPT_PRINTER_CONN_STATE_CONNECTING:
                    Log.d("Printer Connecting", "");
                    break;
                case RECEIPT_PRINTER_CONN_STATE_CONNECTED:
                    Log.d("Printer connected", "");

                    new AsyncPrint().execute();
                    break;
                case RECEIPT_PRINTER_CONN_DEVICE_NAME:
                    Log.d("", "");
                    // mPrinter.connectToPrinter();
                    break;
                case RECEIPT_PRINTER_NOTIFICATION_ERROR_MSG:
                    String n = b.getString(RECEIPT_PRINTER_MSG);
                    break;
            }
        }
    };


    private class AsyncPrint extends AsyncTask<Void, Void, Void> {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
//        bFindBlackMark = cbFindBlackMark.isChecked();
//        cbFindBlackMark.setEnabled(false);
//
//        pdWorkInProgress.setIndeterminate(true);
//        pdWorkInProgress.setMessage("Printing ...");
//        pdWorkInProgress.setCancelable(false); // disable dismiss by tapping outside of the dialog
//        pdWorkInProgress.show();
        }

        @Override
        protected Void doInBackground(Void... params) {
            mPrinter.setPrinterWidth(PrinterWidth.PRINT_WIDTH_48MM);
            mPrinter.resetPrinter();
            //   Bitmap bmp = BitmapFactory.decodeResource(getResources(), R.mipmap.ic_launcher;
//            bmp.setHeight(150);
//            bmp.setHeight(100);
            Bitmap bmp = BitmapFactory.decodeResource(getResources(), R.mipmap.brt);
//            bmp.setHeight(150);
//            bmp.setHeight(100);

            if (!isFineTicket) {
                mPrinter.setAlignmentCenter();
//              mPrinter.setBoldOn();
                mPrinter.setCharRightSpacing(10);
                mPrinter.printGrayScaleImage(bmp, 1);
//              mPrinter.setBoldOff();
                mPrinter.setCharRightSpacing(0);
                mPrinter.pixelLineFeed(50);
                // Bill Details Start
                mPrinter.setAlignmentLeft();
                mPrinter.printTextLine("Name         : " + name + "\n");
                mPrinter.printTextLine("Entry Time   : " + time + "\n");
                mPrinter.printTextLine("Ticket Number: " + number + "\n");
                mPrinter.setAlignmentCenter();
//              mPrinter.printQRcode(number, QRCODE_WIDTH, imageAlignment);
                mPrinter.printQRcode(ticketContent, 300, imageAlignment);
                mPrinter.setAlignmentCenter();
                mPrinter.printTextLine("Maximum Vehicle Speed 40 kmph\n");
                mPrinter.printTextLine("\nViolators will be booked under\nK F ACT 1963 and WP ACT1972\n");
                mPrinter.printLineFeed();
//              mPrinter.setFontStyle(true, true, FontStyle.DOUBLE_HEIGHT, FontType.FONT_A);
                mPrinter.printTextLine("Save Tigers\n");
//              mPrinter.setFontStyle(false, false, FontStyle.NORMAL, FontType.FONT_A);
                mPrinter.printLineFeed();
                mPrinter.printTextLine("******************************\n");
                mPrinter.printLineFeed();
            } else {
                mPrinter.setAlignmentCenter();
                mPrinter.setBoldOn();
                mPrinter.setCharRightSpacing(10);
                mPrinter.printGrayScaleImage(bmp, 1);
                mPrinter.setBoldOff();
                mPrinter.setCharRightSpacing(0);
                mPrinter.pixelLineFeed(50);
                mPrinter.setAlignmentLeft();
                mPrinter.printTextLine("Name          : " + name + "\n");
                mPrinter.printTextLine("Phone Number  : " + phoneNumber + "\n");
                mPrinter.printTextLine("Ticket Number : " + number + "\n");
                mPrinter.printTextLine("Date          : " + date + "\n");
                mPrinter.printTextLine("Time          : " + time + "\n");
                // mPrinter.printTextLine("Ticket Number : " + number + "\n");
                mPrinter.printTextLine("Road          : " + checkPost + "\n");
                mPrinter.printTextLine("Violation     : " + violation + "\n");
                mPrinter.printTextLine("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
                mPrinter.setAlignmentCenter();
                mPrinter.setBoldOn();
                mPrinter.printTextLine("Rs " + fine + " Fine \n");
                mPrinter.setBoldOff();
                mPrinter.printTextLine("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
                if(!(utrId.equals(""))){
                    mPrinter.printTextLine("UTR Number     : " + utrId + "\n");
                }
                mPrinter.printTextLine("\nAs per O.M No. PCCF(WL)/B2/CR-24/2017-18\n");
                mPrinter.setAlignmentCenter();
                mPrinter.printLineFeed();
                mPrinter.printLineFeed();
                mPrinter.printTextLine("******************************\n");
                mPrinter.printLineFeed();
            }


//
//            mPrinter.printTextLine("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
//            mPrinter.printLineFeed();
//
//            mPrinter.setAlignmentCenter();
//
//
//            mPrinter.printLineFeed();
//
//            mPrinter.printBarcode("1234567890123", Barcode.CODE_128, BARCODE_WIDTH, BARCODE_HEIGHT, imageAlignment);
//            //mPrinter.setAlignmentCenter();
//            mPrinter.setCharRightSpacing(10);
//            mPrinter.printTextLine("  1234567890123\n");
//
//            mPrinter.printUnicodeText(" SDK can print in any language that the android device supports and display. \n" +
//                    " English - English \n" +
//                    " kannada - ಕನ್ನಡ \n" +
//                    " Hindi - हिंदी \n" +
//                    " Tamil - தமிழ் \n" +
//                    " Telugu - తెలుగు \n" +
//                    " Marathi - मराठी \n" +
//                    " Malayalam - മലയാളം \n" +
//                    " Gujarati - ગુજરાતી \n" +
//                    " Urdu -  اردو" +
//                    "\n");
//
//            String[] sCol1 = {"ABC", "DEFG", "H", "IJKLM", "XYZ"};
//            PrintColumnParam pcp1stCol = new PrintColumnParam(sCol1, 33, Layout.Alignment.ALIGN_NORMAL, 22, Typeface.create(Typeface.SANS_SERIF, Typeface.NORMAL));
//            String[] sCol2 = {":", ":", ":", ":", ":"};
//            PrintColumnParam pcp2ndCol = new PrintColumnParam(sCol2, 33, Layout.Alignment.ALIGN_CENTER, 22);
//            String[] sCol3 = {"₹1.00", "₹20.00", "₹300.00", "₹4,000.00", "₹50,000.89"};
//            PrintColumnParam pcp3rdCol = new PrintColumnParam(sCol3, 33, Layout.Alignment.ALIGN_OPPOSITE, 22);
//            mPrinter.PrintTable(pcp1stCol, pcp2ndCol, pcp3rdCol);
//
//            Bitmap c1 = BitmapFactory.decodeResource(getResources(), R.drawable.c1_100);
//            Bitmap c2 = BitmapFactory.decodeResource(getResources(), R.drawable.c2_100);
//            PrintImageColumn pic1 = new PrintImageColumn(c1, 50, Layout.Alignment.ALIGN_NORMAL);
//            PrintImageColumn pic2 = new PrintImageColumn(c2, 50, Layout.Alignment.ALIGN_OPPOSITE);
//            mPrinter.PrintImageTable(pic1, pic2);
//            mPrinter.printLineFeed();
//
//            pic1 = new PrintImageColumn(c1, 50, Layout.Alignment.ALIGN_OPPOSITE);
//            pic2 = new PrintImageColumn(c2, 50, Layout.Alignment.ALIGN_NORMAL);
//            mPrinter.PrintImageTable(pic1, pic2);
//            mPrinter.printLineFeed();
//
//            pic1 = new PrintImageColumn(c1, 50, Layout.Alignment.ALIGN_CENTER);
//            pic2 = new PrintImageColumn(c2, 50, Layout.Alignment.ALIGN_CENTER);
//            mPrinter.PrintImageTable(pic1, pic2);
//            mPrinter.printLineFeed();


            //Clearance for Paper tear
            mPrinter.printLineFeed();
            mPrinter.printLineFeed();

//            TextPaint tp = new TextPaint();
//            tp.setColor(Color.BLACK);
//
//            for (int i = 16; i < 48; i++) {
//                tp.setTextSize(i);
//                mPrinter.printUnicodeText("नमस्ते", Layout.Alignment.ALIGN_NORMAL, tp);
//            }
//            mPrinter.printLineFeed();
//            mPrinter.printLineFeed();
//            mPrinter.printLineFeed();
            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            super.onPostExecute(aVoid);
            //wait for printing to complete
            try {
                Thread.sleep(6000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            mPrinter.disconnectFromPrinter();
//            btnPrint.setEnabled(true);
//            cbFindBlackMark.setEnabled(true);
            pdWorkInProgress.cancel();
        }

//        @Override
//        public boolean onCreateOptionsMenu(Menu menu) {
//            getMenuInflater().inflate(R.menu.menu_main, menu);
//            return true;
//        }
//
//        @Override
//        public boolean onOptionsItemSelected(MenuItem item) {
////        int id = item.getItemId();
////        if (id == R.id.action_about) {
////            Toast.makeText(this,"CIE Simple text Print App V2",Toast.LENGTH_LONG).show();
////            return true;
////        }
//            return super.onOptionsItemSelected(item);
//        }
    }
}

