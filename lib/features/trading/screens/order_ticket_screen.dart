import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trading_app/features/trading/bloc/order_bloc.dart';
import 'package:trading_app/features/trading/bloc/order_event.dart';
import 'package:trading_app/features/trading/bloc/order_state.dart';
import 'package:trading_app/features/trading/screens/order_confirmation_screen.dart';
import 'package:trading_app/features/trading/widgets/order_selector.dart';
import 'package:trading_app/features/trading/widgets/order_summary.dart';
import 'package:trading_app/features/trading/widgets/price_card.dart';
import 'package:trading_app/features/trading/widgets/stock_header.dart';

import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../../market/data/datasources/stock_data.dart';
import '../data/models/order_side.dart';

class OrderTicketScreen extends StatefulWidget {
  final String symbol;

  const OrderTicketScreen({super.key, required this.symbol});

  @override
  State<OrderTicketScreen> createState() => _OrderTicketScreenState();
}

class _OrderTicketScreenState extends State<OrderTicketScreen> {
  static const backgroundColor = Color(0xFF0B0F14);
  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);
  static const sellColor = Color(0xFFF87171);

  OrderSide _side = OrderSide.buy;

  final TextEditingController _quantityController = TextEditingController();

  bool _hasEditedQuantity = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String? _validateQuantity(String value) {
    if (value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value);

    if (quantity == null) {
      return 'Enter a whole number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than zero';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stock = StockData.stocks.firstWhere(
      (stock) => stock.symbol == widget.symbol,
    );

    final actionColor = _side == OrderSide.buy ? accentColor : sellColor;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          '${stock.symbol} Order',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state.status == OrderStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Order failed.')),
            );
          }

          if (state.status == OrderStatus.success) {
            final order = state.lastOrder;

            if (order == null) {
              return;
            }

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OrderConfirmationScreen(order: order),
              ),
            );
          }
        },

        child: BlocSelector<MarketBloc, MarketState, MarketPrice?>(
          selector: (state) => state.prices[widget.symbol],

          builder: (context, marketPrice) {
            final ltpPaise = marketPrice?.pricePaise ?? stock.initialPricePaise;

            final quantity = int.tryParse(_quantityController.text) ?? 0;

            final orderValuePaise = quantity * ltpPaise;

            return BlocSelector<OrderBloc, OrderState, int>(
              selector: (state) => state.wallet.balancePaise,

              builder: (context, balancePaise) {
                final insufficientBalance =
                    _side == OrderSide.buy && orderValuePaise > balancePaise;

                final quantityError = _hasEditedQuantity
                    ? _validateQuantity(_quantityController.text)
                    : null;

                final validQuantity = quantity > 0 && quantityError == null;

                final canSubmit = validQuantity && !insufficientBalance;

                return ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                  children: [
                    StockHeader(symbol: stock.symbol, name: stock.name),

                    SizedBox(height: 20.h),

                    PriceCard(ltpPaise: ltpPaise, marketPrice: marketPrice),

                    SizedBox(height: 20.h),

                    OrderSideSelector(
                      side: _side,
                      onChanged: (side) {
                        setState(() {
                          _side = side;
                        });
                      },
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      'Quantity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                      cursorColor: actionColor,
                      decoration: InputDecoration(
                        hintText: 'Enter quantity',
                        hintStyle: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.numbers_rounded,
                          color: secondaryTextColor,
                          size: 20.sp,
                        ),
                        errorText: quantityError,
                        filled: true,
                        fillColor: cardColor,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 15.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                            color: actionColor,
                            width: 1.2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: const BorderSide(color: sellColor),
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _hasEditedQuantity = true;
                        });
                      },
                    ),

                    SizedBox(height: 20.h),

                    // --------------------------------
                    // ORDER SUMMARY
                    // --------------------------------
                    OrderSummary(
                      balancePaise: balancePaise,
                      quantity: quantity,
                      ltpPaise: ltpPaise,
                      orderValuePaise: orderValuePaise,
                    ),

                    // --------------------------------
                    // INSUFFICIENT BALANCE
                    // --------------------------------
                    if (insufficientBalance) ...[
                      SizedBox(height: 12.h),

                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: sellColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: sellColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: sellColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Insufficient balance for this order.',
                                style: TextStyle(
                                  color: sellColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h),

                    // --------------------------------
                    // SUBMIT BUTTON
                    // --------------------------------
                    SizedBox(
                      height: 54.h,
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: actionColor,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: borderColor,
                          disabledForegroundColor: secondaryTextColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        onPressed: canSubmit
                            ? () {
                                _submitOrder(context, stock.symbol, quantity);
                              }
                            : null,
                        child: Text(
                          _side == OrderSide.buy
                              ? 'Buy ${stock.symbol}'
                              : 'Sell ${stock.symbol}',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _submitOrder(BuildContext context, String symbol, int quantity) {
    context.read<OrderBloc>().add(
      SubmitOrder(symbol: symbol, side: _side, quantity: quantity),
    );
  }
}
