
/// The range class gives you a number which is between a min and max number.
/// Usages: -Keeping track of hitpoints or similar metrics
/// -keeping track of ability cool down timers
/// -Generating random numbers within a range
/// -Storing direction angles or other circular data (use looping values)

class Range
{
    float m_max, m_min; //the thresholds for the meter value
    float m_regen; //how many points you want to regenerate/degenerate every second
    float m_current; //the current value of the meter
    bool m_loopValues; //if this is 'true', then the current value will loop between min and max values instead of being capped.
    Range()
    {
        m_max = 100;
        m_min = 0;
        m_current = 100;
        m_regen = 0;
        m_loopValues = false;
    }

    /// Creates a range with the current value at max value and min at zero
    /// <param name="max">the highest range value allowed</param>
    Range(float max)
    {
        m_max = max;
        m_current = max;
        m_min = 0.0f;
        m_loopValues = false;
    }

    /// creates a range value with the current value defaulted to the max value
    /// <param name="min">lowest range value</param>
    /// <param name="max">highest range value</param>
    Range(float min, float max)
    {
        m_max = max;
        m_min = min;
        m_current = max;
        m_loopValues = false;
    }

    /// Creates a range
    /// <param name="min">lowest range value</param>
    /// <param name="max">highest range value</param>
    /// <param name="current">current range value</param>
    Range(float min, float max, float current)
    {
        m_max = max;
        m_min = min;
        m_current = current;
        m_loopValues = false;
    }

    /// creates a range value with regeneration/decay value set so the current value increases/decreases over time
    /// <param name="min">lowest range value</param>
    /// <param name="max">highest range value</param>
    /// <param name="current">current value in range</param>
    /// <param name="regen">the change in current value over time</param>
    Range(float min, float max, float current, float regen)
    {
        m_max = max;
        m_min = min;
        m_current = current;
        m_regen = regen;
        m_loopValues = false;
    }
    Range(Range Copy)
    {
        if (Copy == null)
        return;
        m_max = Copy.m_max;
        m_min = Copy.m_min;
        m_current = Copy.m_current;
        m_regen = Copy.m_regen;
        m_loopValues = Copy.m_loopValues;
    }

    /// The current value will always be between min and max values
    float Current
    {
        get
        {
            return m_current; //E: I'm assuming this gets truncated.
        }
        set
        {
            //do some quick bounds checking
            if (value > m_max) //value is greater than specified max value
            {
                if (m_loopValues)
                {
                //the remaining looped value should be seamlessly added to the minimum value if it overflows the max
                    m_current = m_min + (value % m_max); //tested
                }
                else
                {
                    m_current = m_max;
                }
            }
            else if (value < m_min) //value is less than specified minimum value
            {
                if (m_loopValues)
                {
                    m_current = m_min + (value % (m_max - m_min)); //tested
                }
                else
                {
                    m_current = m_min;
                }
            }
            else
            m_current = value;
        }
    }

    /// Sets the current value to a random number between the min and max range values
    /// <param name="SetCurrent">Flag on whether you want to set the current value to the randomly generated number</param>
    float Random(bool SetCurrent)
    {
        double d = Calc.random.NextDouble();
        float diff = m_max - m_min;
        diff *= (float)d;
        if (SetCurrent == true)
        {
            m_current = m_max - diff;
        }
        return m_max - diff;
    }

    /// Returns a random float which lies between min and max value of the range.
    float Random()
    {
        return Random(false);
    }
    float Max
    {
        get
        {
            return m_max;
        }
        set
        {
            m_max = value;
        }
    }
    float Min
    {
        get
        {
            return m_min;
        }
        set
        {
            m_min = value;
        }
        }
            float Half
        {
        get
        {
            return (m_min + m_max) / 2.0f;
        }
    }

    /// Per second regeneration/decay value for the current value of the meter
    float RegenRate
    {
        get
        {
            return m_regen;
        }
        set
        {
            m_regen = value;
        }
    }
    void Update()
    {
        //are we regenerating/decaying over time?
        if (m_regen != 0)
        {
            Current += m_regen * Time.deltaTime;
        }
    }
    void SetToMax()
    {
        m_current = m_max;
    }
    void SetToMin()
    {
        m_current = m_min;
    }
    bool IsEmpty()
    {
        return (m_current <= m_min);
    }

    /// Set/Get the current value as a percentage of the min and max values
    float Percent
    {
        get
        {
            return ((m_current - m_min) / (m_max - m_min)) * 100;
        }
        set
        {
            m_current = m_min + ((value / 100) * (m_max - m_min));
        }
    }

    /// if this is 'true', then the current value will loop between min and max values instead of being capped.
    /// Default: false
    bool LoopValues
    {
        get
        {
            return m_loopValues;
        }
        set
        {
            m_loopValues = value;
        }
    }

    /// Tells you if the current range value is at the maximum value
    bool IsMax()
    {
        return m_current == m_max;
    }

    /// Tells you if the current range value is at the minimum value
    bool IsMin()
    {
        return m_current == m_min;
    }
}