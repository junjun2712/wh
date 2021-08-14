#property copyright "TPO: Time Price Opportunity (on time range) v3.0. Copyright � FXcoder, 2009-2014"
#property link      "http://fxcoder.ru"
#property strict
#property indicator_chart_window

enum ENUM_TPO_PERIOD {
	TPO_PERIOD_M1 = PERIOD_M1,   // M1 (1 minute)
	TPO_PERIOD_M5 = PERIOD_M5,   // M5 (5 minutes)
	TPO_PERIOD_M15 = PERIOD_M15, // M15 (15 minutes)
	TPO_PERIOD_M30 = PERIOD_M30, // M30 (30 minutes)
	TPO_PERIOD_H1 = PERIOD_H1,   // H1 (1 hour)
	TPO_PERIOD_H4 = PERIOD_H4,   // H4 (4 hours)
	TPO_PERIOD_D1 = PERIOD_D1,   // D1 (1 day)
	TPO_PERIOD_W1 = PERIOD_W1,   // W1 (1 week)
	TPO_PERIOD_MN1 = PERIOD_MN1  // MN1 (1 month)
};

enum ENUM_TPO_HG_STYLE {
	TPO_HG_STYLE_LINES = 0,             // Lines
	TPO_HG_STYLE_EMPTY_RECTANGLES = 1,  // Empty rectangles
	TPO_HG_STYLE_FILLED_RECTANGLES = 2  // Filled rectangles
};

enum ENUM_TPO_VOLUME_TYPE {
	TPO_VOLUME_TYPE_TICK = 1,  // Tick volume
	TPO_VOLUME_TYPE_REAL = 2   // Real volume
};

enum ENUM_TPO_RANGE_MODE {
	TPO_RANGE_MODE_BETWEEN_LINES = 0,   // Between lines
	TPO_RANGE_MODE_LAST_MINUTES = 1,    // Last minutes
	TPO_RANGE_MODE_MINUTES_TO_LINE = 2  // Minitues to line
};

enum ENUM_TPO_HG_POSITION {
	TPO_HG_POSITION_WINDOW_LEFT = 0,  // Window left
	TPO_HG_POSITION_WINDOW_RIGHT = 1, // Window right
	TPO_HG_POSITION_LEFT_OUTSIDE = 2,    // Left outside
	TPO_HG_POSITION_RIGHT_OUTSIDE = 3,   // Right outside
};

/* ��������� �������� */
// ��������: 0 - ����� ������������ �����, 1 - ��������� RangeMinutes �����, 2 = RangeMinutes ����� ������
extern ENUM_TPO_RANGE_MODE RangeMode = TPO_RANGE_MODE_BETWEEN_LINES; // Range mode

// ���������� ����� � ��������� (��� ��������� ����� �������� ������)
extern int RangeMinutes = 1440; // Range minutes

// ��� ������ ���, ���������� � 2 ���� ������ + 1
extern int ModeStep = 10; // Mode step (points)

// ������� �����������, ����������� �������� ����������������� ���������� ����� ��������� ����� ���
int Smooth = 0;

// ��� ����, 0 - ���� (��. #1)
int PriceStep = 0;

// ������ ��� ������, ������� - ����� ������
ENUM_TPO_PERIOD DataPeriod = TPO_PERIOD_M1;

// ��� ������ ��� �������
extern ENUM_TPO_VOLUME_TYPE VolumeType = TPO_VOLUME_TYPE_TICK; // Volume type

// �������� �������� ������
bool ShowHorizon = true;

/* ����������� � ���� */
// 0 - window left, 1 - window right, 2 - left side, 3 - right side,
extern ENUM_TPO_HG_POSITION HGPosition = TPO_HG_POSITION_WINDOW_RIGHT; // Histogram position

// ���� �����������
extern color HGColor = C'160,224,160'; // Histogram color (None=disable)

// ����� �����������: 0 - �����, 1 - ������ ��������������, 2 - ����������� ��������������
extern ENUM_TPO_HG_STYLE HGStyle = TPO_HG_STYLE_EMPTY_RECTANGLES; // Histogram bar style

// ���� ���
extern color ModeColor = Green; // Mode color (None=disable)

// �������� ��������
extern color MaxModeColor = CLR_NONE; // Mode color (maximum volume, None=disable)

// ������ ����� �����������
int HGLineWidth = 1;

// ������� �����������, 0 - �����������
double Zoom = 0;

// ������� ���
int ModeWidth = 1;

// ����� ���
ENUM_LINE_STYLE ModeStyle = STYLE_SOLID;

/* ������ */
// ���� �������
extern color ModeLevelColor = Green; // Mode level line color (None=disable)

// �������
int ModeLevelWidth = 1;

// �����
extern ENUM_LINE_STYLE ModeLevelStyle = STYLE_DOT; // Mode level line style

/* ��������� */
// ������� ���� �������� ����������
extern string Id = "+tpor"; // Identifier

// ����������� �����, � ��������, ����� ������������
int WaitSeconds = 1;

// ����� ������� ��������� - ����
color TimeFromColor = Blue;
// ����� ������� ��������� - �����
ENUM_LINE_STYLE TimeFromStyle = STYLE_DASH;

// ������ ������� ��������� - ����
color TimeToColor = Red;
// ������ ������� ��������� - �����
ENUM_LINE_STYLE TimeToStyle = STYLE_DASH;

string _onp, _tfn, _ttn;
datetime _lastTime = 0;   // ��������� ����� �������

double _hgPoint;          // ����������� ��������� ����
int _modeStep = 0;

bool _showHG, _showModes, _showMaxMode, _showModeLevel;
bool _hgBack = true;
bool _hgUseRectangles = false;

int init()
{
	_onp = Id + " m" + IntegerToString(RangeMode) + " ";
	_tfn = Id + "-from";
	_ttn = Id + "-to";

	_hgPoint = Point;

	bool is5digits = ((Digits == 3) || (Digits == 5)) && (MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0);

	//#1
	if (PriceStep == 0)
	{
		if (is5digits)
			_hgPoint = Point * 10.0;
	}
	else
	{
		_hgPoint = Point * PriceStep;
	}

	if (is5digits)
		_modeStep = (int)(10 * ModeStep * Point / _hgPoint);
	else
		_modeStep = (int)(ModeStep * Point / _hgPoint);

	// ��������� �����������
	_showHG = !ColorIsNone(HGColor);
	_showModes = !ColorIsNone(ModeColor);
	_showMaxMode = !ColorIsNone(MaxModeColor);
	_showModeLevel = !ColorIsNone(ModeLevelColor);

	// ������������ ��������� �����
	if (HGStyle == TPO_HG_STYLE_EMPTY_RECTANGLES)
	{
		_hgBack = false;
		_hgUseRectangles = true;
	}
	else if (HGStyle == TPO_HG_STYLE_FILLED_RECTANGLES)
	{
		_hgBack = true;
		_hgUseRectangles = true;
	}

	return(0);
}

int start()
{
	if (GlobalVariableGet("+vl-freeze") == 1)
		return(0);

	datetime currentTime = TimeLocal();

	// ������ ����������� �� ����� ����...
	if (Volume[0] > 1)
	{
		// ...� �� ����, ��� ��� � ��������� ������
		if (currentTime - _lastTime < WaitSeconds)
			return(0);
	}

	_lastTime = currentTime;

	// ������� ������ �������
	clearChart(_onp);

	// ���������� ������� ��������

	datetime timeFrom, timeTo;

	if (RangeMode == 0)	// ����� ���� �����
	{
		timeFrom = GetObjectTime1(_tfn);
		timeTo = GetObjectTime1(_ttn);

		if ((timeFrom == 0) || (timeTo == 0))
		{
			// ���� ������� ��������� �� ������, �� ������������� �� � ������� ����� ������
			datetime timeLeft = getBarTime(WindowFirstVisibleBar());
			datetime timeRight = getBarTime(WindowFirstVisibleBar() - WindowBarsPerChart());
			ulong r = timeRight - timeLeft;

			timeFrom = (datetime)(timeLeft + r / 3);
			timeTo = (datetime)(timeLeft + r * 2 / 3);

			drawVLine(_tfn, timeFrom, TimeFromColor, 1, TimeFromStyle, false);
			drawVLine(_ttn, timeTo, Crimson, 1, STYLE_DASH, false);
		}

		if (timeFrom > timeTo)
		{
			datetime dt = timeTo;
			timeTo = timeFrom;
			timeFrom = dt;
		}
	}
	else if (RangeMode == 2)	// �� ������ ����� RangeMinutes �����
	{
		timeTo = GetObjectTime1(_ttn);
		int bar;

		if (timeTo == 0)
		{
			// ���� ������ ��������� �� �����, �� ������������� ��� � ������� ����� ������
			bar = MathMax(0, WindowFirstVisibleBar() - WindowBarsPerChart() + 20);
			timeTo = getBarTime(bar);
		}
		else
		{
			bar = iBarShift(NULL, 0, timeTo);
		}

		bar += RangeMinutes / Period();
		timeFrom = Time[bar];

		drawVLine(_tfn, timeFrom, TimeFromColor, 1, TimeFromStyle, false);

		if (ObjectFind(_ttn) == -1)
			drawVLine(_ttn, timeTo, TimeToColor, 1, TimeToStyle, false);
	}
	else if (RangeMode == 1)
	{
		timeFrom = iTime(Symbol(), PERIOD_M1, RangeMinutes);
		timeTo = iTime(Symbol(), PERIOD_M1, 0);

		// ������� ����� ������
		clearChart(_tfn);
		clearChart(_ttn);
	}
	else
	{
		return(0);
	}

	if (getTimeBar(timeTo) < 0)
		timeTo = iTime(Symbol(), PERIOD_M1, 0);

	if (getTimeBar(timeFrom) < 0)
		timeFrom = iTime(Symbol(), PERIOD_M1, 0);

	if (ShowHorizon)
	{
		datetime hz = iTime(NULL, DataPeriod, iBars(NULL, DataPeriod) - 1);
		drawVLine(_onp + "hz", hz, Red, 1, STYLE_DOT, false);
	}

	int barFrom, barTo, m1BarFrom, m1BarTo;

	if (getRange(timeFrom, timeTo, barFrom, barTo, m1BarFrom, m1BarTo, DataPeriod))
	{
		// �������� �����������
		double vh[], hLow;

		int count = getHGByRates(m1BarFrom, m1BarTo, vh, hLow, _hgPoint, DataPeriod, VolumeType);

		if (count == 0)
			return(0);

		if (Smooth != 0)
		{
			count = smoothHG(vh, Smooth);
			hLow -= Smooth * _hgPoint;
		}

		int rp;

		double windowTimeRange = WindowBarsPerChart() * Period() * 60;
		rp = (int)(windowTimeRange * 0.1); // �������� ������� ��� ��������� �����������

		// ����������� ��������
		double zoom = Zoom * 0.000001;

		if (zoom <= 0)
		{
			double maxVolume = vh[ArrayMaximum(vh)];
			zoom = WindowBarsPerChart() * 0.1 / maxVolume;
		}

		int bar0;	// ��� ������� ������� �����������

		if (HGPosition == 0)		// ����� ������� ����
		{
			bar0 = WindowFirstVisibleBar();
		}
		else if (HGPosition == 1)	// ������ ������� ����
		{
			bar0 = WindowFirstVisibleBar() - WindowBarsPerChart();
			zoom = -zoom; // ������ ��������������
		}
		else if (HGPosition == 2)	// ����� ������� ���������
		{
			bar0 = barFrom;
			zoom = -zoom; // ������ ��������������
		}
		else 						// 3 - ������ ������� ���������
		{
			bar0 = barTo;
		}

		// ������
		if (_showHG)
			drawHG(_onp + "hg ", vh, hLow, bar0, HGColor, HGColor, zoom, HGLineWidth, _hgPoint);

		if (_showModes || _showMaxMode || _showModeLevel)
		{
			// ����� ���
			int modes[];
			int modeCount = getModes(vh, _modeStep, modes);

			drawModes(vh, hLow, modes, bar0, zoom, _hgPoint);

			if (_showModeLevel)
				drawModesLevels(vh, hLow, modes, _hgPoint);
		}
	}

	return(0);
}

int deinit()
{
	// ������� ��� ����������� � �� �����������
	clearChart(_onp);

	// ������� ����� ������ ��� ����� �������� ���������� � �������
	if (UninitializeReason() == REASON_REMOVE)
	{
		clearChart(_tfn);
		clearChart(_ttn);
	}

	return(0);
}

void DrawHLine(string name, double price, color lineColor = Gray, int width = 1, int style = STYLE_SOLID, bool back = true)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);

	if (price > 0 && ObjectCreate(name, OBJ_HLINE, 0, 0, price))
	{
		ObjectSet(name, OBJPROP_COLOR, lineColor);
		ObjectSet(name, OBJPROP_WIDTH, width);
		ObjectSet(name, OBJPROP_STYLE, style);
		ObjectSet(name, OBJPROP_BACK, back);
	}
}

datetime GetObjectTime1(string name)
{
	// ��������� ������� ObjectGet � ������ ���������� ������� �� �������������� �������������� �����, ������� �����������
 	if (ObjectFind(name) != -1)
		return((datetime)ObjectGet(name, OBJPROP_TIME1));

	return(0);
}

// ���������� ������ ��� �����������
void drawModesLevels(double& vh[], double hLow, int& modes[], double point)
{
	// ������� ������ ������ ���, ��� ����� ������ ���������
	clearChart(_onp + "level ");

	for (int j = 0, modeCount = ArraySize(modes); j < modeCount; j++)
	{
		double price = hLow + modes[j] * point;

		// �������
		if (_showModeLevel)
			DrawHLine(_onp + "level " + DoubleToStr(price, Digits), price, ModeLevelColor, ModeLevelWidth, ModeLevelStyle, true);
	}
}

// �������� ����� ���� �� ������� � ������ ���������� ������ �� �������� �������� ������
int getTimeBar(datetime time, int period = 0)
{
	if (period == 0)
		period = Period();

	int shift = iBarShift(Symbol(), period, time);
	datetime t = getBarTime(shift, period);

	if (t != time)
		shift = (int)((iTime(Symbol(), period, 0) - time) / 60 / period);

	return(shift);
}

#import "gdi32.dll"
uint GetPixel(int hDC, int x, int y);
#import

int IntPutInRange(int value, int from, int to)
{
	if (to >= from)
	{
		if (value > to)
			value = to;
		else if (value < from)
			value = from;
	}

	return(value);
}

double DoublePutInRange(double value, double from, double to)
{
	if (to >= from)
	{
		if (value > to)
			value = to;
		else if (value < from)
			value = from;
	}

	return(value);
}

bool ColorToRGB(color c, int& r, int& g, int& b)
{
	// ���� ���� ����� ��������, ���� ����� ��� �������������, ������� false
	if ((c >> 24) > 0)
	{
		r = 255;
		g = 255;
		b = 255;
		return(false);
	}

	// 0x00BBGGRR
	b = (c & 0xFF0000) >> 16;
	g = (c & 0x00FF00) >> 8;
	r = (c & 0x0000FF);

	return(true);
}

color RGBToColor(int r, int g, int b)
{
	// 0x00BBGGRR
	return((color)(
	    ((b & 0x0000FF) << 16) + ((g & 0x0000FF) << 8) + (r & 0x0000FF)
	    ));
}

color MixColors(color color1, color color2, double mix, double step = 16)
{
	// ��������� ����������
	step = DoublePutInRange(step, 1.0, 255.0);
	mix = DoublePutInRange(mix, 0.0, 1.0);

	int r1, g1, b1;
	int r2, g2, b2;

	// ������� �� ����������
	ColorToRGB(color1, r1, g1, b1);
	ColorToRGB(color2, r2, g2, b2);

	// ���������
	int r = IntPutInRange((int)(MathRound((r1 + mix * (r2 - r1)) / step) * step), 0, 255);
	int g = IntPutInRange((int)(MathRound((g1 + mix * (g2 - g1)) / step) * step), 0, 255);
	int b = IntPutInRange((int)(MathRound((b1 + mix * (b2 - b1)) / step) * step), 0, 255);

	return(RGBToColor(r, g, b));
}

bool ColorIsNone(color c)
{
	return((c >> 24) > 0);
}

#define ERR_HISTORY_WILL_UPDATED 4066

// �������� ����� �� ������ ���� � ������ ���������� ������ �� �������� ����� (����� ���� ������ 0)
datetime getBarTime(int shift, int period = 0)
{
	if (period == 0)
		period = Period();

	if (shift >= 0)
		return(iTime(Symbol(), period, shift));
	else
		return(iTime(Symbol(), period, 0) - shift*period*60);
}

// �������� ������ �� ����� ��������
int clearChart(string prefix)
{
	int count = 0;

	for (int i = ObjectsTotal() - 1; i >= 0; i--)
	{
		string name = ObjectName(i);

		if (StringFind(name, prefix) == 0)
		{
			ObjectDelete(name);
			count++;
		}
	}

	return(count);
}

void drawVLine(string name, datetime time1, color lineColor = Gray, int width = 1, int style = STYLE_SOLID, bool back = true)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);

	ObjectCreate(name, OBJ_VLINE, 0, time1, 0);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
}

void drawBar(string name, datetime time1, double price1, datetime timeTo, double price2,
	color lineColor, int width, int style, bool back, bool ray, int window, bool useRectangle,
	double hgPoint)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);

	// ���� �������� ����������������, �� ��� ��������� ��� �� �����������
	if (useRectangle)
		ObjectCreate(name, OBJ_RECTANGLE, window, time1, price1 - hgPoint / 2.0, timeTo, price2 + hgPoint / 2.0);
	else
		ObjectCreate(name, OBJ_TREND, window, time1, price1, timeTo, price2);

	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
	ObjectSet(name, OBJPROP_RAY, ray);

	ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
	ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

// ���������� ����������� (+���� +point)
void drawHG(string prefix, double& h[], double low, int barFrom, color bgColor, color lineColor, double zoom, int width, double point)
{
	double max = h[ArrayMaximum(h)];

	if (max == 0)
		return;

	int bgR, bgG, bgB;
    if (!ColorToRGB(bgColor, bgR, bgG, bgB))
        return;

	int lineR, lineG, lineB;
    if (!ColorToRGB(lineColor, lineR, lineG, lineB))
        return;

	int dR = lineR - bgR;
	int dG = lineG - bgG;
	int dB = lineB - bgB;

	for (int i = 0, hc = ArraySize(h); i < hc; i++)
	{
		double price = NormalizeDouble(low + i * point, Digits);

		int barTo = (int)(barFrom - h[i] * zoom);

		// ��������� ����������
		color cl = MixColors(bgColor, lineColor, h[i] / max);

		datetime timeFrom = getBarTime(barFrom);
		datetime timeTo = getBarTime(barTo);

		if (barFrom != barTo)
			drawBar(prefix + DoubleToStr(price, Digits), timeFrom, price, timeTo, price, cl, width, STYLE_SOLID, _hgBack, false, 0, _hgUseRectangles, point);
	}
}

// �������� ��������� ���������
bool getRange(datetime timeFrom, datetime timeTo, int& barFrom, int& barTo, int& p1BarFrom, int& p1BarTo, int period)
{
	// �������� ����� � ������� �� (��� ���������)

	barFrom = iBarShift(NULL, 0, timeFrom);
	datetime time = Time[barFrom];
	int bar = iBarShift(NULL, 0, time);
	time = Time[bar];

	if (time != timeFrom)
		barFrom--;

	barTo = iBarShift(NULL, 0, timeTo);
	time = Time[barTo];
	bar = iBarShift(NULL, 0, time);
	time = Time[bar];

	if (time == timeFrom)
		barTo++;

	if (barFrom < barTo)
		return(false);

	// �������� ����� �� period (��� ��������� ������)

	p1BarFrom = iBarShift(NULL, period, timeFrom);
	time = iTime(NULL, period, p1BarFrom);

	if (time != timeFrom)
		p1BarFrom--;

	p1BarTo = iBarShift(NULL, period, timeTo);
	time = iTime(NULL, period, p1BarTo);

	if (timeTo == time)
		p1BarTo++;

	if (p1BarFrom < p1BarTo)
		return(false);

	return(true);
}

// �������� ����������� ������������� ���
//		m1BarFrom, m1BarTo - ������� ���������, �������� �������� ����� �������
// ����������:
//		��������� - ���������� ��� � �����������, 0 - ������
//		vh - �����������
//		hLow - ������ ������� �����������
//		point - ��� ����
//		dataPeriod - ��������� ������
int getHGByRates(int m1BarFrom, int m1BarTo, double& vh[], double& hLow, double point, int dataPeriod, ENUM_TPO_VOLUME_TYPE volumeType)
{
	MqlRates rates[];
	double hHigh;

	// ����������������� (� ������������) ���������� �������
	int rCount = getRates(m1BarFrom, m1BarTo, rates, hLow, hHigh, dataPeriod);

	if (rCount == 0)
	    return(0);

	hLow = NormalizeDouble(MathRound(hLow / point) * point, Digits);
	hHigh = NormalizeDouble(MathRound(hHigh / point) * point, Digits);

	// �������������� ������ �����������
	int hCount = (int)(MathRound(hHigh / point) - MathRound(hLow / point) + 1);
	ArrayResize(vh, hCount);
	ArrayInitialize(vh, 0);

	int iCount = m1BarFrom - m1BarTo + 1;
	int hc = calcHGByRates(rates, rCount, iCount, m1BarTo, point, hLow, hCount, vh, volumeType);

	if (hc == hCount)
		return(hc);

	return(0);
}

// �������� ����������� ������������� ���
int calcHGByRates(MqlRates& rates[], int rcount, int icount, int ishift, double point, double hLow, int hCount, double& vh[], ENUM_TPO_VOLUME_TYPE volumeType)
{
	int pri;   // ������ ����
	double dv; // ����� �� ���

	int hLowI = (int)MathRound(hLow / point);

	for (int j = 0; j < icount; j++)
	{
		int i = j + ishift;

		double o = rates[i].open;
		int oi = (int)MathRound(o / point);

		double h = rates[i].high;
		int hi = (int)MathRound(h / point);

		double l = rates[i].low;
		int li = (int)MathRound(l / point);

		double c = rates[i].close;
		int ci = (int)MathRound(c / point);

		long v = volumeType == TPO_VOLUME_TYPE_REAL ? rates[i].real_volume : rates[i].tick_volume;

		// ��� ������� ������ ���������� ������
		if (v == 0)
			return 0;

		int rangeMin = hLowI;
		int rangeMax = hLowI + hCount - 1;

		// �������� �����
		if (c >= o)     // ����� �����
		{
			dv = v / (oi - li + hi - li + hi - ci + 1.0);

			for (pri = oi; pri >= li; pri--)        // open --> low
				vh[pri - hLowI] += dv;

			for (pri = li + 1; pri <= hi; pri++)    // low+1 ++> high
				vh[pri - hLowI] += dv;

			for (pri = hi - 1; pri >= ci; pri--)    // high-1 --> close
				vh[pri - hLowI] += dv;
		}
		else            // �������� �����
		{
			dv = v / (hi - oi + hi - li + ci - li + 1.0);

			for (pri = oi; pri <= hi; pri++)        // open ++> high
				vh[pri - hLowI] += dv;

			for (pri = hi - 1; pri >= li; pri--)    // high-1 --> low
				vh[pri - hLowI] += dv;

			for (pri = li + 1; pri <= ci; pri++)    // low+1 ++> close
				vh[pri - hLowI] += dv;
		}
	}

	return(hCount);
}

// �������� ���� �� ������ ����������� � ���������� ����������� (������� �����, ��� �����������)
int getModes(double& vh[], int modeStep, int& modes[])
{
	int modeCount = 0;
	ArrayFree(modes);

	// ���� ��������� �� ��������
	for (int i = modeStep, count = ArraySize(vh); i < count - modeStep; i++)
	{
		int maxFrom = i - modeStep;
		int maxRange = 2 * modeStep + 1;
		int maxTo = maxFrom + maxRange - 1;

		int k = ArrayMaximum(vh, maxRange, maxFrom);

		if (k == i)
		{
			for (int j = i - modeStep; j <= i + modeStep; j++)
			{
				if (vh[j] == vh[k])
				{
					modeCount++;
					ArrayResize(modes, modeCount);
					modes[modeCount-1] = j;
				}
			}
		}

	}

	return(modeCount);
}

// �������� ������� ��� ��������� ��������� (����������� � ������� ����� �������)
int getRates(int barFrom, int barTo, MqlRates& rates[], double& ilowest, double& ihighest, int period)
{
	// ����������������� (� ������������) ���������� �������
	int iCount = barFrom - barTo + 1;
	int count = ArrayCopyRates(rates, NULL, period);

	if (GetLastError() == ERR_HISTORY_WILL_UPDATED)
		return(0);

	if (count < barFrom - 1)
	    return(0);

	ilowest = iLow(NULL, period, iLowest(NULL, period, MODE_LOW, iCount, barTo));
	ihighest = iHigh(NULL, period, iHighest(NULL, period, MODE_HIGH, iCount, barTo));
	return(count);
}

int smoothHG(double& vh[], int depth)
{
	int vCount = ArraySize(vh);

	if (depth == 0)
		return(vCount);

	// ��������� ������ (���������� ��� ���������� ��������)
	int newCount = vCount + 2 * depth;

	// �������� �������� � �������� ������
	double th[];
	ArrayResize(th, newCount);
	ArrayInitialize(th, 0);

	ArrayCopy(th, vh, depth, 0);

	ArrayResize(vh, newCount);
	ArrayInitialize(vh, 0);

	// ���������������� ����������
	for (int d = 0; d < depth; d++)
	{
		for (int i = -d; i < vCount + d; i++)
			vh[i+depth] = (th[i+depth-1] + th[i+depth] + th[i+depth+1]) / 3.0;

		ArrayCopy(th, vh);
	}

	ArrayResize(vh, vCount);
	ArrayCopy(vh, th, 0, depth, vCount);

	return(newCount);
}

// ���������� ���� �����������
void drawModes(double& vh[], double hLow, int& modes[], int barFrom, double zoom, double point)
{
	int modeCount = ArraySize(modes);
	int j;
	double price;

	// ����. ����
	double max = 0;

	if (_showMaxMode)
	{
		for (j = 0; j < modeCount; j++)
		{
			if (vh[modes[j]] > max)
				max = vh[modes[j]];
		}
	}

	datetime timeFrom = getBarTime(barFrom);

	string namePrefix = _onp + "mode " + TimeToStr(timeFrom) + " ";

	// ������� ������ ���� � �� ������, ��� ����� ������ ���������
	clearChart(namePrefix);

	bool back = _hgUseRectangles;
	string on;

	for (j = 0; j < modeCount; j++)
	{
		double v = zoom * vh[modes[j]];

		// �� �������� �������� ����� (������ ���� ��), ������ ��� ��������� ������
		if (MathAbs(v) > 0)
		{
			price = hLow + modes[j] * point;
			datetime timeTo = getBarTime((int)(barFrom - v));

			on = _onp + namePrefix + DoubleToStr(price, Digits);

			if (_showMaxMode && (MathAbs(vh[modes[j]] - max) < point))	// ������������ ����
			{
				drawBar(on, timeFrom, price, timeTo, price, MaxModeColor, ModeWidth, ModeStyle, back, false, 0, _hgUseRectangles, point);

				// � ������ ��������� ���������������� ���� ������ �������, ����� ��� ����������
				if (_hgUseRectangles && back)
					drawBar(on + "+", timeFrom, price, timeTo, price, MaxModeColor, ModeWidth, ModeStyle, false, false, 0, false, point);
			}
			else if (_showModes)	// ������� ����
			{
				drawBar(on, timeFrom, price, timeTo, price, ModeColor, ModeWidth, ModeStyle, back, false, 0, _hgUseRectangles, point);

				// � ������ ��������� ���������������� ���� ������ �������, ����� ��� ����������
				if (_hgUseRectangles && back)
					drawBar(on + "+", timeFrom, price, timeTo, price, ModeColor, ModeWidth, ModeStyle, false, false, 0, false, point);
			}
		}
	}
}

// 2014-02-22 01:05:32 UTC
// MQLMake 1.20. Copyright � FXcoder, 2011-2014. http://fxcoder.ru